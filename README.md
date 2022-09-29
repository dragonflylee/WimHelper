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

[Win10 ESD](https://go.microsoft.com/fwlink/?LinkId=841361)
[Win11 ESD](https://go.microsoft.com/fwlink/?LinkId=2156292)

系统|版本号|32位|64位
----|------|----|----
Win10 1709|[10.0.16299.15](https://download.microsoft.com/download/A/F/7/AF7CF8A4-9A20-4117-A0A1-4243F835D2BF/ProductsRS3RTM10032017.xml)|[China](http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2017/10/16299.15.170928-1534.rs3_release_clientchina_ret_x86fre_zh-cn_1e9f9ef43f16fdd67a2cc4749ed6c38c9058705c.esd) [Consumer](http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2017/10/16299.15.170928-1534.rs3_release_clientconsumer_ret_x86fre_zh-cn_b411ad9fd3236d4cf5ec7d3debe0ef155791995f.esd) [Business](http://wsus.ds.b1.download.windowsupdate.com/c/upgr/2017/10/16299.15.170928-1534.rs3_release_clientbusiness_vol_x86fre_zh-cn_4b0a6afdf690b2424f083d4b6633dd9f7f1ab0e1.esd)|[China](http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2017/10/16299.15.170928-1534.rs3_release_clientchina_ret_x64fre_zh-cn_b96c8d4f2beb0666dc965ed012bc59468269e1d8.esd) [Consumer](http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2017/10/16299.15.170928-1534.rs3_release_clientconsumer_ret_x64fre_zh-cn_cc52c191fda2caff9d5b6730ee88a11758dc0138.esd) [Business](http://wsus.ds.b1.download.windowsupdate.com/c/upgr/2017/10/16299.15.170928-1534.rs3_release_clientbusiness_vol_x64fre_zh-cn_d6bf989c6b57c7246fa72fec1e564808c3ee3255.esd)
Win10 1803|[10.0.17134.1](https://download.microsoft.com/download/F/1/2/F12AE2F0-B1CC-4A83-9529-C3D43F171C62/Products_RS4_04_20_2018.xml)|[China](http://fg.ds.b1.download.windowsupdate.com/d/Upgr/2018/04/17134.1.180410-1804.rs4_release_clientchina_ret_x86fre_zh-cn_0ef82b3951d42794d72dcfbcbf6af34cd20ddee8.esd) [Consumer](http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2018/04/17134.1.180410-1804.rs4_release_clientconsumer_ret_x86fre_zh-cn_5aa044757d64492bb3de8a6995deacabc21d11f8.esd) [Business](http://fg.ds.b1.download.windowsupdate.com/d/Upgr/2018/04/17134.1.180410-1804.rs4_release_clientbusiness_vol_x86fre_zh-cn_082e2466d6c169e0ca10a69950007b8ab0cbe4f5.esd)|[China](http://fg.ds.b1.download.windowsupdate.com/d/Upgr/2018/04/17134.1.180410-1804.rs4_release_clientchina_ret_x64fre_zh-cn_de20e00e3402b9c1ac776cc2f449fefcc410e477.esd) [Consumer](http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2018/04/17134.1.180410-1804.rs4_release_clientconsumer_ret_x64fre_zh-cn_3571ad559ed85ff28889671984c46b3939c00255.esd) [Business](http://fg.ds.b1.download.windowsupdate.com/d/Upgr/2018/04/17134.1.180410-1804.rs4_release_clientbusiness_vol_x64fre_zh-cn_4aa8fe6b27eb0ea1eb49b04867d3cab7ca9b3bdd.esd)
Win10 1809|[10.0.17763.1](https://download.microsoft.com/download/8/D/F/8DF0EA49-0A7B-4F4D-A6DE-4DF7FA00FB7B/products.xml)|[China](http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2018/09/17763.1.180914-1434.rs5_release_clientchina_ret_x86fre_zh-cn_05e2e97808fd65cd436f8c6775e8392dc0322bc3.esd) [Consumer](http://fg.ds.b1.download.windowsupdate.com/d/Upgr/2018/09/17763.1.180914-1434.rs5_release_clientconsumer_ret_x86fre_zh-cn_54b4a7b7733479a4e4da0878bcf6908256488bbb.esd) [Business](http://fg.ds.b1.download.windowsupdate.com/d/Upgr/2018/09/17763.1.180914-1434.rs5_release_clientconsumer_ret_x86fre_zh-cn_54b4a7b7733479a4e4da0878bcf6908256488bbb.esd) |[China](http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2018/09/17763.1.180914-1434.rs5_release_clientchina_ret_x64fre_zh-cn_6483d851ed114f553018b53f2374deff9cd51115.esd) [Consumer](http://fg.ds.b1.download.windowsupdate.com/d/Upgr/2018/09/17763.1.180914-1434.rs5_release_clientconsumer_ret_x64fre_zh-cn_1a644e45bd9b1b88b45a7d345d5b63ca589813e4.esd) [Business](http://fg.ds.b1.download.windowsupdate.com/c/Upgr/2018/09/17763.1.180914-1434.rs5_release_clientbusiness_vol_x64fre_zh-cn_a37dc7f616f37aa1f7a775b68144ad474086e190.esd)
Win10 1809|[10.0.17763.107](https://download.microsoft.com/download/6/F/1/6F1E072F-1D14-489F-8438-C586D720CA32/products.xml)|[China](http://fg.ds.b1.download.windowsupdate.com/d/Upgr/2018/11/17763.107.101029-1455.rs5_release_svc_refresh_clientchina_ret_x86fre_zh-cn_35f233ebfd4a774d3fa2726b968537f14f56c677.esd) [Consumer](http://fg.ds.b1.download.windowsupdate.com/d/Upgr/2018/11/17763.107.101029-1455.rs5_release_svc_refresh_clientconsumer_ret_x86fre_zh-cn_33d17f983288e50e2c7f8f8d850ecda18cd1a7e4.esd) [Business](http://fg.ds.b1.download.windowsupdate.com/d/Upgr/2018/11/17763.107.101029-1455.rs5_release_svc_refresh_clientbusiness_vol_x86fre_zh-cn_c1f870502498090cd581c547a0bed90dd1473a0a.esd)|[China](http://fg.ds.b1.download.windowsupdate.com/d/Upgr/2018/11/17763.107.101029-1455.rs5_release_svc_refresh_clientchina_ret_x64fre_zh-cn_e82f7d5eab7e108b31626380baa726397934c875.esd) [Consumer](http://fg.ds.b1.download.windowsupdate.com/d/Upgr/2018/11/17763.107.101029-1455.rs5_release_svc_refresh_clientconsumer_ret_x64fre_zh-cn_ff25cc7118b470a71966c973cd68e24d4f7df30a.esd) [Business](http://fg.ds.b1.download.windowsupdate.com/d/Upgr/2018/11/17763.107.101029-1455.rs5_release_svc_refresh_clientbusiness_vol_x64fre_zh-cn_a4991f267f93943292dad5c66eaa4796bd859279.esd)
Win10 1909|[10.0.18363.592](https://download.microsoft.com/download/8/2/b/82b12fa5-cab6-4d37-8167-16630c6151eb/products_20200116.cab)|[China](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/24144db7-8f02-4f85-85d5-41e5ed950456/18363.592.200109-2016.19h2_release_svc_refresh_CLIENTCHINA_RET_x86FRE_zh-cn.esd) [Consumer](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/03002f08-8550-4b69-866f-cd499087432d/18363.592.200109-2016.19h2_release_svc_refresh_CLIENTCONSUMER_RET_x86FRE_zh-cn.esd) [Business](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/7817c270-7e3d-4ac7-b40a-c7f248964360/18363.592.200109-2016.19h2_release_svc_refresh_CLIENTBUSINESS_VOL_x86FRE_zh-cn.esd)|[China](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/6c61feca-c932-4299-9876-5d2cd1aa5e58/18363.592.200109-2016.19h2_release_svc_refresh_CLIENTCHINA_RET_x64FRE_zh-cn.esd) [Consumer](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/3f88ad25-f1b2-49fa-b580-fb8d1ac54ecb/18363.592.200109-2016.19h2_release_svc_refresh_CLIENTCONSUMER_RET_x64FRE_zh-cn.esd) [Business](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/f9525f5e-75b3-430e-b304-d4dcf29577f9/18363.592.200109-2016.19h2_release_svc_refresh_CLIENTBUSINESS_VOL_x64FRE_zh-cn.esd)
Win10 2004|[10.0.19041.450](https://download.microsoft.com/download/f/b/6/fb681a0f-af38-433d-acdd-9060aaeca46c/products_20200808.cab)|[China](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/65e5033f-a935-4a1c-bf46-1337689f665a/19041.450.200808-0726.vb_release_svc_refresh_CLIENTCHINA_RET_x86FRE_zh-cn.esd) [Consumer](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/067b19ea-f410-4e14-b1ed-e5e4d83811a0/19041.450.200808-0726.vb_release_svc_refresh_CLIENTCONSUMER_RET_x86FRE_zh-cn.esd) [Business](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/3929856d-4651-4ab8-9f90-7b989e3c97f6/19041.450.200808-0726.vb_release_svc_refresh_CLIENTBUSINESS_VOL_x86FRE_zh-cn.esd)|[China](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/eee63b53-5914-451e-8ede-6689b7578348/19041.450.200808-0726.vb_release_svc_refresh_CLIENTCHINA_RET_x64FRE_zh-cn.esd) [Consumer](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/eb8ce721-0c63-4da7-ae8d-328cd18d8f37/19041.450.200808-0726.vb_release_svc_refresh_CLIENTCONSUMER_RET_x64FRE_zh-cn.esd) [Business](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/387f9f1b-4eab-4a69-b9b1-ebe373a1ff3d/19041.450.200808-0726.vb_release_svc_refresh_CLIENTBUSINESS_VOL_x64FRE_zh-cn.esd)
Win10 2009|[10.0.19042.631](https://download.microsoft.com/download/4/3/0/430e9adb-cf08-4b68-9032-eafca8378d42/products_20201119.cab)|[China](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/928ca4a5-3133-454c-9b9b-e88744ae53ce/19042.572.201009-1947.20h2_release_svc_refresh_CLIENTCHINA_RET_x86FRE_zh-cn.esd) [Consumer](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/88b307b0-8c8e-445c-a982-4b93f7cb7d82/19042.572.201009-1947.20h2_release_svc_refresh_CLIENTCONSUMER_RET_x86FRE_zh-cn.esd) [Business](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/e498c321-d9f5-4567-9d8c-c13d224ee1c3/19042.572.201009-1947.20h2_release_svc_refresh_CLIENTBUSINESS_VOL_x86FRE_zh-cn.esd)|[China](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/d6d55ed3-1abe-4ced-8ec2-439c75184a77/19042.572.201009-1947.20h2_release_svc_refresh_CLIENTCHINA_RET_x64FRE_zh-cn.esd) [Consumer](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/2b709225-1f5f-4226-bebe-609d84c77aac/19042.572.201009-1947.20h2_release_svc_refresh_CLIENTCONSUMER_RET_x64FRE_zh-cn.esd) [Business](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/eda4de41-fbfb-47aa-b37e-530f48a11a09/19042.572.201009-1947.20h2_release_svc_refresh_CLIENTBUSINESS_VOL_x64FRE_zh-cn.esd)
Win10 21h2|[10.0.19044.1288](https://download.microsoft.com/download/3/9/6/396ae429-afb2-49da-81d8-c16c6782d082/products_Win10_20211115.cab)|[China](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/8bc210e9-c232-474a-9fe3-361a41616e80/19044.1288.211006-0501.21h2_release_svc_refresh_CLIENTCHINA_RET_x86FRE_zh-cn.esd) [Consumer](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/10612ea6-de4f-4304-adfd-614c4b09b252/19044.1288.211006-0501.21h2_release_svc_refresh_CLIENTCONSUMER_RET_x86FRE_zh-cn.esd) [Business](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/73a9cc2d-276b-4131-920d-0badc353f690/19044.1288.211006-0501.21h2_release_svc_refresh_CLIENTBUSINESS_VOL_x86FRE_zh-cn.esd)|[China](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/ab5b15da-a74a-4474-974d-0098eca751b6/19044.1288.211006-0501.21h2_release_svc_refresh_CLIENTCHINA_RET_x64FRE_zh-cn.esd) [Consumer](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/e7aa8b81-ee80-4b52-8f04-c364f0ce1af1/19044.1288.211006-0501.21h2_release_svc_refresh_CLIENTCONSUMER_RET_x64FRE_zh-cn.esd) [Business](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/c16e22d4-7faa-4d7e-8d15-e3730219827c/19044.1288.211006-0501.21h2_release_svc_refresh_CLIENTBUSINESS_VOL_x64FRE_zh-cn.esd)
Win10 22h2|[10.0.19045.2006](https://download.microsoft.com/download/e/6/c/e6c6ef82-8b05-4c0f-9852-d2b86129de29/products_Win10_20220916.cab)|[China](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/2f69de2d-8881-448a-8510-29d66f612576/19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTCHINA_RET_x86FRE_zh-cn.esd) [Consumer](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/324cef54-c8ed-4a59-a661-312965806cf3/19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTCONSUMER_RET_x86FRE_zh-cn.esd) [Business](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/2a61a343-b0b7-46e4-8361-0e7f8c9159c1/19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTBUSINESS_VOL_x86FRE_zh-cn.esd)|[China](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/1d9e5688-3afb-4133-b711-2c9a0c4b22b5/19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTCHINA_RET_x64FRE_zh-cn.esd) [Consumer](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/5fdb4d51-62f0-41bb-9487-d80b18bc11f7/19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTCONSUMER_RET_x64FRE_zh-cn.esd) [Business](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/a6fca105-b105-4b13-b98b-74848e48e3e8/19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTBUSINESS_VOL_x64FRE_zh-cn.esd)
Win11 22h2|[10.0.22621.525](https://download.microsoft.com/download/a/e/5/ae50fa4c-e37b-4ef1-bf6b-60a0e4382d08/products_Win11_20220926.cab)||[China](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/bb82f18d-5184-420c-bd2e-0ba3e8ac2528/22621.525.220925-0207.ni_release_svc_refresh_CLIENTCHINA_RET_x64FRE_zh-cn.esd) [Consumer](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/9282e556-e4ce-4e75-a650-3b8dea2f060a/22621.525.220925-0207.ni_release_svc_refresh_CLIENTCONSUMER_RET_x64FRE_zh-cn.esd) [Business](http://dl.delivery.mp.microsoft.com/filestreamingservice/files/c1dd582c-68cb-4c22-8926-637352b88992/22621.525.220925-0207.ni_release_svc_refresh_CLIENTBUSINESS_VOL_x64FRE_zh-cn.esd)

### 2. 更新补丁获取

访问 [Microsoft Update Catalog](http://www.catalog.update.microsoft.com/Home.aspx) 在搜索补丁下载地址，以下是 Win10 补丁搜索的快捷连接

系统|版本号|更新
----|------|-------
Win10 1607|10.0.14393|[32位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201607+x86) [64位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201607+x64)
Win10 1703|10.0.15063|[32位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201703+x86) [64位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201703+x64)
Win10 1709|10.0.16299|[32位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201709+x86) [64位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201709+x64)
Win10 1803|10.0.17134|[32位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201803+x86) [64位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201803+x64)
Win10 1809|10.0.17763|[32位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201809+x86) [64位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201809+x64)
Win10 1903|10.0.18362|[32位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201903+x86) [64位](http://www.catalog.update.microsoft.com/Search.aspx?q=Windows%2010%20Version%201903+x64)

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

应用安装器的ID为 9NBLGGH4NNS1

VP9 9N4D0MSMP0PT


## 使用说明

下载 [WimHelper-master.zip](https://github.com/dragonflylee/WimHelper/archive/master.zip) 并解压, 目录结构如下

![](https://github.com/dragonflylee/WimHelper/blob/master/dir.png)

运行 `WimHelper.cmd [wim镜像路径]` 即可享受全自动镜像处理   