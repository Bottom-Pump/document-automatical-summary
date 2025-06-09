## 概述

该脚本是一个自动化技术文档摘要处理系统，使用DeepSeek大模型生成文档摘要，并通过ROUGE指标评估摘要质量。系统支持处理PDF、DOCX和文本格式的文档，并将结果存储在MySQL数据库中 。

## 功能特点

- 📄 支持多种文档格式：PDF、DOCX和文本文件
- 🤖 使用DeepSeek大模型生成专业摘要
- 📊 基于ROUGE-1指标评估摘要质量
- 💾 结果存储在MySQL数据库
- 🔍 识别低质量摘要文档(ROUGE-1 < 0.5)

## 环境要求

- Python 3+

- MySQL 5.7+

- 以下Python库：

  ```
  volcenginesdkarkruntime
  rouge-chinese
  jieba
  PyPDF2
  python-docx
  ```

## 安装与配置

### 1. 安装依赖

```
pip install pymysql
pip install --upgrade "volcengine-python-sdk[ark]"
pip install rouge-chinese
pip install jieba
pip install --upgrade PyPDF2 python-docx jieba rouge-chinese pymysql volcengine-python-sdk[ark]
```

### 2. 数据库配置

本实验使用mysql数据库存储信息

1. 数据库准备： 运行文件包中的` database.sql` 以创建所需要的数据库

2. 数据库参数修改为本地参数

```python
# 创建MySQL数据库连接
def create_db_connection():
    return pymysql.connect(
        host='localhost',# 运行在本地的mysql数据库
        port=3306, # 本地mysql运行端口
        user='root', # 用户名
        password='123456', # 密码
        # 下文无需更改
        database='knowledge_base', 
        charset='utf8mb4', 
        cursorclass=pymysql.cursors.DictCursor
    )
```

### 3. 大模型配置

在火山引擎注册账号并选择deepseek-v3 241226 版本，替换api密钥为自己的

```python
# DeepSeek API配置
client = Ark(
    base_url="https://ark.cn-beijing.volces.com/api/v3",
    api_key="707f20c5-b84a-XXXXXXXXXX",  # 替换为您的API密钥
)
```

如果使用别的模型可以自己参照sdk中的示例文档修改上文及下文调用代码

```python
def generate_summary(document_content):
    """使用DeepSeek模型生成摘要"""
    if not document_content.strip():
        return ""

    # 截取前6000字符（模型可能有长度限制）
    content = document_content[:6000]

    try:
        response = client.chat.completions.create(
            model="deepseek-v3-241226",
            messages=[
                {"role": "system",
                 "content": "你是一个专业的技术文档摘要生成器。请用一句话（不超过25字）准确概括文档核心内容。"},
                {"role": "user", "content": f"请为以下技术文档生成一句话摘要：\n\n{content}"}
            ],
            max_tokens=50,  # 限制生成长度
            temperature=0.3  # 降低随机性
        )
        return response.choices[0].message.content.strip()
    except Exception as e:
        print(f"摘要生成失败: {str(e)}")
        return ""

```

### 4. 总结文档准备

本次作业为图简便采用硬编码，更改"D:/docs/Docker_K8S.pdf"可以检索到指定文件夹下的文件，

后续有需要可以优化地址检索保存方式

```python
sample_docs = [
    ("Docker_K8S", "D:/docs/Docker_K8S.pdf", "Docker容器技术与 Kubernetes 架构及应用实践"),
    ("软件设计文档", "D:/docs/软件设计文档.docx", "基于 SpringBoot 的读书笔记共享平台设计与实现"),
    ("error_code", "D:/docs/error_code.txt", "MySQL 服务器和客户端错误代码及消息解析")
]
```

## 工作流程

1. 从数据库获取文档信息
2. 提取文档内容（支持PDF/DOCX/TXT）
3. 使用DeepSeek模型生成摘要（限制25字内）
4. 保存摘要到数据库
5. 使用参考摘要计算ROUGE-1分数
6. 存储评估结果
7. 识别低质量摘要文档

## 本地运行结果测试

文件地址

![屏幕截图 2025-06-09 154903](images\屏幕截图 2025-06-09 154903.png)

运行结果

![屏幕截图 2025-06-09 152647](images\屏幕截图 2025-06-09 152647.png)

数据库三个表

![屏幕截图 2025-06-09 155508](images\屏幕截图 2025-06-09 155508.png)

相关文件已打包至压缩包，可自行测试