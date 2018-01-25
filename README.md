# Wim 封装助手

参考 [MSMG ToolKit](https://forums.mydigitallife.net/threads/msmg-toolkit.50572/) 编写的Windows安装镜像处理脚本

* WimExport.cmd 用于制作多合一镜像自动生成镜像描述
* WimHelper.cmd 用于镜像精简优化修改
* MakeISO.cmd   用于ISO镜像生成

## 目录说明

* Pack\Appx       UWP应用程序目录
* Pack\Extra      额外集成包目录
* Pack\NetFx3     .Net3.5 封包目录
* Pack\Optimize   注册表优化相关
* Pack\RollupFix  积累更新目录(需要重启系统才能安装的更新)
* Pack\Update     更新目录(无需重启便能安装的更新，如Flash更新)

## 使用配置

运行批处理前需先配置好 Pack 中的优化设定

### 1. 安装镜像获取

访问 https://tb.rg-adguard.net/index.php 下载原版镜像

系统|版本号|32位|64位
----|------|----|----
Win10 1709|[10.0.16299.15](https://download.microsoft.com/download/A/F/7/AF7CF8A4-9A20-4117-A0A1-4243F835D2BF/ProductsRS3RTM10032017.xml)|[China](http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2017/10/16299.15.170928-1534.rs3_release_clientchina_ret_x86fre_zh-cn_1e9f9ef43f16fdd67a2cc4749ed6c38c9058705c.esd) [Consumer](http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2017/10/16299.15.170928-1534.rs3_release_clientconsumer_ret_x86fre_zh-cn_b411ad9fd3236d4cf5ec7d3debe0ef155791995f.esd) [Business](http://wsus.ds.b1.download.windowsupdate.com/c/upgr/2017/10/16299.15.170928-1534.rs3_release_clientbusiness_vol_x86fre_zh-cn_4b0a6afdf690b2424f083d4b6633dd9f7f1ab0e1.esd)|[China](http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2017/10/16299.15.170928-1534.rs3_release_clientchina_ret_x64fre_zh-cn_b96c8d4f2beb0666dc965ed012bc59468269e1d8.esd) [Consumer](http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2017/10/16299.15.170928-1534.rs3_release_clientconsumer_ret_x64fre_zh-cn_cc52c191fda2caff9d5b6730ee88a11758dc0138.esd) [Business](http://wsus.ds.b1.download.windowsupdate.com/c/upgr/2017/10/16299.15.170928-1534.rs3_release_clientbusiness_vol_x64fre_zh-cn_d6bf989c6b57c7246fa72fec1e564808c3ee3255.esd)
Win10 1709|[10.0.16299.125](https://download.microsoft.com/download/6/B/E/6BE41520-60B6-4F34-AECE-A5EBFA9155B3/ProductsRS312152017.xml)|[China](http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2017/12/16299.125.171213-1220.rs3_release_svc_refresh_clientchina_ret_x86fre_zh-cn_94ebddec3f8b8d1f89ef377a71c6e6580ab25fa9.esd) [Consumer](http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2017/12/16299.125.171213-1220.rs3_release_svc_refresh_clientconsumer_ret_x86fre_zh-cn_ed3dad3c008e7947679689491971e027db03a0f9.esd)| [China](http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2017/12/16299.125.171213-1220.rs3_release_svc_refresh_clientchina_ret_x64fre_zh-cn_57a3ca8dc6d5e83c220cb77464afeb869ef2d983.esd) [Consumer](http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2017/12/16299.125.171213-1220.rs3_release_svc_refresh_clientconsumer_ret_x64fre_zh-cn_a706bd3db9fe8d00ad1df2a1ae680ee54278878d.esd)

### 2. 更新补丁获取

访问 [Microsoft Update Catalog](http://www.catalog.update.microsoft.com/Home.aspx) 在搜索补丁下载地址，以下是 Win10 补丁搜索的快捷连接

系统|版本号|更新
----|------|-------
Win10 1607|10.0.14393|[32位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201607+x86) [64位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201607+x64)
Win10 1703|10.0.15063|[32位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201703+x86) [64位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201703+x64)
Win10 1709|10.0.16299|[32位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201709+x86) [64位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201709+x64)

其中积累更新放置到 `Pack\RollupFix\镜像版本号`，Flash 和其他更新放置到 `Pack\Update\镜像版本号`

### 3. .Net 3.5 封包获取

系统|版本号|更新
----|------|-------
Win10 1709|10.0.16299|[32位](http://download.windowsupdate.com/d/msdownload/update/software/updt/2017/10/microsoft-windows-netfx3-ondemand-package_d3d134a6c583c6c481d9c8cd075bd5d39a8f0a51.cab) [64位](http://download.windowsupdate.com/c/msdownload/update/software/updt/2017/10/microsoft-windows-netfx3-ondemand-package_57a139ab7ec48a144affd233a83fb579f873e856.cab)

### 4. 组件精简设定

修改 `Pack\RemoveList.镜像版本号.txt` 中组件包列表，
组件包名称可通过 [SxsHelper](https://github.com/dragonflylee/SxsHelper/releases) 的导出功能获取

### 5. 开始菜单布局设定

首先设置好当前系统的开始菜单布局，
然后在 PowerShell 中输入命令 `Export-StartLayout –path StartLayout.xml`，
将生成的 xml 复制到 Pack 目录中覆盖同名文件

### 6. UWP应用获取

首先停止 wuauserv 服务并删除  `%WinDir%\SoftwareDistribution\DataStore` 目录

之后在商店中购买下载安装应用

再次停止 wuauserv 服务，并打开 [ESEDatabaseView](http://www.nirsoft.net/utils/ese_database_view.html), 选择 Files => Open SoftwareDistribution Database => 选择 tbFiles 表，在 Urls 那一列找到 AppxBundle 文件的下载地址 (此Url临时有效，时间长了会过期)


## 使用说明

下载 [WimHelper-master.zip](https://github.com/dragonflylee/WimHelper/archive/master.zip) 并解压, 目录结构如下

![](https://github.com/dragonflylee/WimHelper/blob/master/dir.png)

运行 `WimHelper.cmd [wim镜像路径]` 即可享受全自动镜像处理   