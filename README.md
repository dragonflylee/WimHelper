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
Win10 1803|[10.0.17134.1](https://download.microsoft.com/download/F/1/2/F12AE2F0-B1CC-4A83-9529-C3D43F171C62/Products_RS4_04_20_2018.xml)|[China](http://fg.ds.b1.download.windowsupdate.com/d/Upgr/2018/04/17134.1.180410-1804.rs4_release_clientchina_ret_x86fre_zh-cn_0ef82b3951d42794d72dcfbcbf6af34cd20ddee8.esd) [Consumer](http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2018/04/17134.1.180410-1804.rs4_release_clientconsumer_ret_x86fre_zh-cn_5aa044757d64492bb3de8a6995deacabc21d11f8.esd) |[China](http://fg.ds.b1.download.windowsupdate.com/d/Upgr/2018/04/17134.1.180410-1804.rs4_release_clientchina_ret_x64fre_zh-cn_de20e00e3402b9c1ac776cc2f449fefcc410e477.esd) [Consumer](http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2018/04/17134.1.180410-1804.rs4_release_clientconsumer_ret_x64fre_zh-cn_3571ad559ed85ff28889671984c46b3939c00255.esd)
Win10 1809|[10.0.17763.1](https://download.microsoft.com/download/F/1/2/F12AE2F0-B1CC-4A83-9529-C3D43F171C62/Products_RS4_04_20_2018.xml)|[China](http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2018/09/17763.1.180914-1434.rs5_release_clientchina_ret_x86fre_zh-cn_05e2e97808fd65cd436f8c6775e8392dc0322bc3.esd) [Consumer](http://fg.ds.b1.download.windowsupdate.com/d/Upgr/2018/09/17763.1.180914-1434.rs5_release_clientconsumer_ret_x86fre_zh-cn_54b4a7b7733479a4e4da0878bcf6908256488bbb.esd) [Business](http://fg.ds.b1.download.windowsupdate.com/d/Upgr/2018/09/17763.1.180914-1434.rs5_release_clientconsumer_ret_x86fre_zh-cn_54b4a7b7733479a4e4da0878bcf6908256488bbb.esd) |[China](http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2018/09/17763.1.180914-1434.rs5_release_clientchina_ret_x64fre_zh-cn_6483d851ed114f553018b53f2374deff9cd51115.esd) [Consumer](http://fg.ds.b1.download.windowsupdate.com/d/Upgr/2018/09/17763.1.180914-1434.rs5_release_clientconsumer_ret_x64fre_zh-cn_1a644e45bd9b1b88b45a7d345d5b63ca589813e4.esd) [Business](http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2018/09/17763.1.180914-1434.rs5_release_clientbusiness_vol_x64fre_zh-cn_a37dc7f616f37aa1f7a775b68144ad474086e190.esd)

### 2. 更新补丁获取

访问 [Microsoft Update Catalog](http://www.catalog.update.microsoft.com/Home.aspx) 在搜索补丁下载地址，以下是 Win10 补丁搜索的快捷连接

系统|版本号|更新
----|------|-------
Win10 1607|10.0.14393|[32位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201607+x86) [64位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201607+x64)
Win10 1703|10.0.15063|[32位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201703+x86) [64位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201703+x64)
Win10 1709|10.0.16299|[32位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201709+x86) [64位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201709+x64)
Win10 1803|10.0.17134|[32位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201803+x86) [64位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201803+x64)
Win10 1809|10.0.17763|[32位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201809+x86) [64位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201809+x64)

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

访问 https://store.rg-adguard.net/ 下载 appx 包
比如应用商店的ID为 9WZDNCRFJBMP

## 使用说明

下载 [WimHelper-master.zip](https://github.com/dragonflylee/WimHelper/archive/master.zip) 并解压, 目录结构如下

![](https://github.com/dragonflylee/WimHelper/blob/master/dir.png)

运行 `WimHelper.cmd [wim镜像路径]` 即可享受全自动镜像处理   