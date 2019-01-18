#include <windows.h>
#include <tchar.h>
#include <WtsApi32.h>
#pragma comment(lib,"WtsApi32.lib")

/**
* 启动服务并返回进程ID
*/
DWORD NSStartService(LPCTSTR szName)
{
    DWORD dwBytesNeeded, dwWaitTime, dwOldCheckPoint = 0;
    ULONGLONG dwStartTickCount;
    SERVICE_STATUS_PROCESS ssp = { 0 };
    SC_HANDLE hService = NULL;
    SC_HANDLE hSCM = OpenSCManager(NULL, NULL, SC_MANAGER_CONNECT);
    if (NULL == hSCM) goto exit;

    hService = OpenService(hSCM, szName, SERVICE_QUERY_STATUS | SERVICE_START);
    if (NULL == hService) goto exit;

    dwStartTickCount = GetTickCount64();
    while (QueryServiceStatusEx(hService, SC_STATUS_PROCESS_INFO, (LPBYTE)&ssp, sizeof(ssp), &dwBytesNeeded))
    {
        if (SERVICE_STOPPED == ssp.dwCurrentState)
        {
            if (!StartService(hService, 0, NULL)) goto exit;
        }
        else if (SERVICE_STOP_PENDING == ssp.dwCurrentState || SERVICE_START_PENDING == ssp.dwCurrentState)
        {
            dwWaitTime = ssp.dwWaitHint / 10;
            if (dwWaitTime < 1000) dwWaitTime = 1000;
            else if (dwWaitTime > 10000) dwWaitTime = 10000;

            if (ssp.dwCheckPoint > dwOldCheckPoint)
            {
                // Continue to wait and check.
                dwStartTickCount = GetTickCount64();
                dwOldCheckPoint = ssp.dwCheckPoint;
            }
            else if (GetTickCount64() - dwStartTickCount > ssp.dwWaitHint)
            {
                SetLastError(ERROR_TIMEOUT);
                goto exit;
            }
        }
        else
        {
            break;
        }
    }
exit:
    if (SERVICE_RUNNING != ssp.dwCurrentState) memset(&ssp, 0, sizeof(ssp));
    if (NULL != hService) CloseServiceHandle(hService);
    if (NULL != hSCM) CloseServiceHandle(hSCM);
    return ssp.dwProcessId;
}

/**
* 复制进程Token
*/
HANDLE NSDuplicateProcessToken(DWORD dwProcessID, SECURITY_IMPERSONATION_LEVEL ImpersonationLevel, TOKEN_TYPE TokenType)
{
    HANDLE hToken = NULL, hNewToken = NULL;
    HANDLE hProcess = OpenProcess(MAXIMUM_ALLOWED, FALSE, dwProcessID);
    if (NULL == hProcess) return NULL;

    // 打开进程令牌
    if (OpenProcessToken(hProcess, MAXIMUM_ALLOWED, &hToken))
    {
        DuplicateTokenEx(hToken, MAXIMUM_ALLOWED, NULL, ImpersonationLevel, TokenType, &hNewToken);
        CloseHandle(hToken);
    }
    CloseHandle(hProcess);
    return hNewToken;
}

// Enabling and Disabling Privileges
BOOL NSSetPrivilege(HANDLE hToken, LPCTSTR szPrivilege, BOOL bEnable = TRUE)
{
    TOKEN_PRIVILEGES tp;
    LUID luid;

    if (!LookupPrivilegeValue(NULL, szPrivilege, &luid)) return FALSE;

    tp.PrivilegeCount = 1;
    tp.Privileges[0].Luid = luid;
    tp.Privileges[0].Attributes = bEnable ? SE_PRIVILEGE_ENABLED : 0;

    // Enable the privilege or disable all privileges.
    return AdjustTokenPrivileges(hToken, FALSE, &tp, 0, NULL, NULL);
}

DWORD NSFindProcesses(DWORD dwSessionId, LPCTSTR szName)
{
    PWTS_PROCESS_INFO pi = NULL;
    DWORD dwCount = 0, dwProcessId = 0;
    if (!WTSEnumerateProcesses(WTS_CURRENT_SERVER_HANDLE, 0, 1, &pi, &dwCount)) return FALSE;

    for (DWORD i = 0; i < dwCount; ++i)
    {
        if (pi[i].SessionId != dwSessionId) continue;
        if (pi[i].pProcessName == NULL) continue;
        if (_tcsicmp(szName, pi[i].pProcessName) == 0)
        {
            dwProcessId = pi[i].ProcessId;
            break;
        }
    }
    if (NULL != pi) WTSFreeMemory(pi);
    return dwProcessId;
}

/**
* 启动进程并等待
*/
BOOL NSRun(HANDLE hToken, LPTSTR szCmd, int nCmdShow = SW_SHOW, DWORD dwFlags = CREATE_NO_WINDOW)
{
    PROCESS_INFORMATION pi = { 0 };
    STARTUPINFO si = { sizeof(si) };
    si.dwFlags = STARTF_USESHOWWINDOW;
    si.wShowWindow = (WORD)nCmdShow;

    if (!CreateProcessAsUser(hToken, NULL, szCmd, NULL, NULL, FALSE, dwFlags, NULL, NULL, &si, &pi)) return FALSE;

    WaitForSingleObject(pi.hProcess, INFINITE);
    return CloseHandle(pi.hProcess);
}

#define BOOL_CHECK(_hr_) if (!(_hr_)) { hr = GetLastError(); goto exit; }

int APIENTRY _tWinMain(HINSTANCE hInstance,
    HINSTANCE hPrevInstance,
    LPTSTR    lpCmdLine,
    int       nCmdShow)
{
    UNREFERENCED_PARAMETER(hInstance);
    UNREFERENCED_PARAMETER(hPrevInstance);

    if (!(*lpCmdLine)) return MessageBox(HWND_DESKTOP, TEXT("Thanks M2Team"), TEXT("NSudo"), MB_ICONASTERISK);

    HRESULT hr = S_OK;
    HANDLE hToken = NULL, hTokenWinLogon = NULL, hTokenTrusted = NULL;
    DWORD dwTrusted, dwSessionId, dwWinLogon, dwReturn;

    BOOL_CHECK(OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hToken));
    BOOL_CHECK(GetTokenInformation(hToken, TokenSessionId, &dwSessionId, sizeof(DWORD), &dwReturn));
    BOOL_CHECK(NSSetPrivilege(hToken, SE_DEBUG_NAME));
    // 获取 WinLogon 的权限
    dwWinLogon = NSFindProcesses(dwSessionId, TEXT("winlogon.exe"));
    BOOL_CHECK(dwWinLogon);
    hTokenWinLogon = NSDuplicateProcessToken(dwWinLogon, SecurityImpersonation, TokenImpersonation);
    BOOL_CHECK(hTokenWinLogon);
    BOOL_CHECK(NSSetPrivilege(hTokenWinLogon, SE_ASSIGNPRIMARYTOKEN_NAME));
    BOOL_CHECK(SetThreadToken(NULL, hTokenWinLogon));
    // 获取 TrustedInstaller 的权限
    dwTrusted = NSStartService(TEXT("TrustedInstaller"));
    BOOL_CHECK(dwTrusted);
    hTokenTrusted = NSDuplicateProcessToken(dwTrusted, SecurityIdentification, TokenPrimary);
    BOOL_CHECK(hTokenTrusted);
    BOOL_CHECK(SetTokenInformation(hTokenTrusted, TokenSessionId, &dwSessionId, sizeof(DWORD)));
    // 启动进程
    BOOL_CHECK(NSRun(hTokenTrusted, lpCmdLine, nCmdShow));
exit:
    if (NULL != hTokenWinLogon) CloseHandle(hTokenWinLogon);
    if (NULL != hTokenTrusted) CloseHandle(hTokenTrusted);
    if (NULL != hToken) CloseHandle(hToken);
    return hr;
}
