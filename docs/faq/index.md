---
layout: default
title: FAQ
nav_order: 4
has_children: true
---

# FAQ

问答按**指南章节归类**,不按时间排序。这是刻意的:复习时你是带着"我在看 5 级流水线"
这样的上下文来找答案的,而不是"我上个月问过什么"。

| 分类 | 覆盖 |
|---|---|
| [环境与安装]({{ site.baseurl }}/faq/environment.html) | Setup、Chipyard、submodule |
| [核的规模与选型]({{ site.baseurl }}/faq/cores.html) | 指南 §1 |
| [构建与运行流程]({{ site.baseurl }}/faq/toolflow.html) | 指南 §2、§8 |
| [测量方法]({{ site.baseurl }}/faq/measurement.html) | 指南 §6 |
| [写测试程序]({{ site.baseurl }}/faq/testing.html) | 指南 §7.5 |

右上角的搜索框是全文搜索,包括 FAQ 和指南正文。

## 加新条目的规范

一条 FAQ 值得写下来,当且仅当它满足**至少一条**:

- 花了超过十分钟才搞清楚
- 答案违反直觉(比如 5 级流水线的 CPI 比单周期还差)
- 是个会重复踩的坑

不满足的就别写 —— FAQ 的价值在于信噪比,写成聊天记录就废了。

格式:

```markdown
## 问题原话?

**答:** 结论先行,一两句话说清。

然后是为什么,以及能验证这个结论的具体命令或代码位置。

> 相关:指南 [§N 章节名](链接)
```
