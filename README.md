# IDM激活脚本中文汉化版

一个用于激活和重置[Internet Download Manager](https://www.internetdownloadmanager.com/)试用版的开源工具

## 特点

-   使用注册表密钥锁定方法激活IDM
-   激活后即使安装IDM更新也会保持有效
-   IDM试用重置
-   完全开源
-   基于透明的批处理脚本

## 下载 / 如何使用？

-   首先全新安装[Internet Download Manager](https://www.internetdownloadmanager.com/)，确保删除/卸载以前的破解/补丁（如果有的话）
-   然后按照以下步骤激活：

### 方法1 - Github Releases

（推荐，通过此方法下载的程序为汉化版，更适合中国宝宝体制👶）

-   从[GitHub](https://raw.githubusercontent.com/yhgzs-111/IDM-Activation-Script-ZH/main/IAS(%E6%B1%89%E5%8C%96).cmd)下载cmd文件
-   右键单击下载的zip文件并解压缩
-   在提取的文件夹中，运行名为`IAS.cmd`的文件
-   您将看到激活选项，请按照屏幕上的说明操作

### 方法2 - PowerShell

（通过此方法下载的为原版，即英文版）

-   在Windows 8.1/10/11上，右键单击Windows开始菜单，选择PowerShell或终端（不是CMD）
-   复制粘贴下面的代码，然后按Enter键\
    `irm https://massgrave.dev/ias | iex`
-   你将看到激活选项，请按照屏幕上的说明操作

## 汉化版已知问题
选项2（激活）汉化后会出错（应该），求大佬帮忙提交PRs

## 一些信息

#### 激活

-   该脚本应用注册表锁定方法激活Internet Download Manager（IDM）
-   此方法要求在激活时连接到互联网
-   可以直接安装IDM更新，无需再次激活
-   激活后，如果在某些情况下，IDM开始显示激活提示屏幕，只需再次运行激活选项，而不使用重置选项

#### 重置IDM激活 / 试用

-   Internet Download Manager提供30天的试用期，您可以使用此脚本在需要时重置此激活 / 试用期
-   如果IDM报告虚假序列号和其他类似错误，此选项也可用于恢复状态

#### 操作系统要求

-   该项目支持Windows 7/8/8.1/10/11及其服务器等效版本
-   在Windows 8及更高版本上支持使用PowerShell方法运行IAS

#### 高级信息

-   要在IDM许可信息中添加自定义名称，请编辑脚本文件中的第29行
-   要在无人值守模式下激活，请使用`/act`参数运行脚本
-   要在无人值守模式下重置，请使用`/res`参数运行脚本

## 工作原理

-   IDM在各种注册表键中存储与试用和激活相关的数据。其中一些键已锁定以防止篡改，并以一种模式存储数据，以跟踪虚假序列号问题和剩余的试用天数。为了激活它，这里的脚本只需通过在IDM中触发一些下载来生成这些注册表键，识别这些注册表键，并将其锁定，以便IDM无法编辑和查看它们。这样，IDM就无法显示使用虚假序列号激活的警告。

## 故障排除

-   浏览器集成修复：[Chrome](https://www.internetdownloadmanager.com/register/new_faq/bi9.html) - [Firefox](https://www.internetdownloadmanager.com/register/new_faq/bi4.html)

## 截图

![](https://massgrave.dev/IAS.png?raw=true)

![](https://massgrave.dev//IAS_Activation.png?raw=true)

## 鸣谢

|                                             |                                                                                                                                                                                                                                        |
|----------------|--------------------------------------------------------|
| Dukun Cabul                                 | IDM试用重置和激活逻辑的原始研究者，为这些方法创建了一个Autoit工具，名为[IDM-AIO_2020_Final](https://nsaneforums.com/topic/371047-discussion-internet-download-manager-fixes/page/8/#comment-1632062) |
| AveYo aka BAU                               | [提供了简洁、高效的相关注册表代码片段](https://pastebin.com/XTPt0JSC)                                                                                                                                                                         |
| [abbodi1406](https://github.com/abbodi1406) | 在编码方面提供帮助                                                                                                                                                                                                                         |
| WindowsAddict                               | 脚本作者                                                                                                                                                                                                                             |
| [yhgzs-111](https://github.com/yhgzs-111)                                    | 中文汉化                                                                                                                                                                                                                          |
