# Sea.js for Rails 3.x

Integrates Sea.js into the Rails 3 Asset Pipeline.  
提供一种将 Sea.js 与 Asset Pipeline 结合起来的方式，底层通过 spm-chaos-build 来实现

## 安装

首先请安装好 spm-chaos-build ，参见 https://github.com/edokeh/spm-chaos-build

    $ npm install spm -g
    $ npm install spm-chaos-build -g

然后在 Gemfile 中添加这个 gem

    gem 'seajs-rails'

并执行命令

    $ bundle

## 使用方式

### 初始化

执行以下命令初始化项目

    $ rake seajs:setup

这会安装最新版本的 Sea.js 到相应目录下，并在 config 目录生成 seajs_config.yml

配置文件说明：

```yaml
seajs_path: seajs/seajs/2.0.0/sea.js  # 这是配置 seajs 的路径
family: klog  # 与打包合并有关的参数，自动生成为项目的名称，一般不需要修改
output:  # 合并策略，具体参见 spm-chaos-build
  relative:
    - application.js
  all: []
```

ouput 项其实就是 package.json 中的 spm.output
支持 relative（只合并相对路径）, all（合并所有路径） 两种方式

目录说明：

    your-rails
    ├─app
    │  ├─assets
    │  │  ├─images
    │  │  ├─javascripts
    │  │  │  ├─a.js    <-- your js code
    │  │  │  └─sea-modules    <-- seajs base 目录
    │  │  │      ├─gallery
    │  │  │      ├─jquery
    │  │  │      └─seajs
    │  │  │          └─seajs
    │  │  │              └─2.0.0
    │  │  └─stylesheets

与普通的开发基本一致，只是在 javascripts 目录下多了一个 sea-modules 作为 Sea.js 的 base 目录
普通的业务代码依然放置在 javascripts 目录下（非 CMD 模块的 JS 也放在这里）

### 使用

提供两个 helper 方法：seajs_tag 与 seajs_use

```erb
<%= seajs_tag %>
<%= seajs_use 'blogs/show' %>
```
seajs_tag 用于引入 seajs ，并且会根据是否合并引入必要的配置
seajs_use 用于加载 CMD 模块，支持传递多个模块名称

### 合并

这个 gem 会将 seajs 的打包合并过程嵌入到 assets:precompile 任务中，所以执行这个命令

    $ rake assets:precompile

Sea.js 的合并过程不会与原有的 assets pipeline 冲突，但是请将配置分开
* 需要合并的 CMD 模块文件请在 seajs_config.yml 中配置
* 而非 CMD 模块的文件请依然通过 `config.assets.precompile` 配置

合并完成后，不需要改动页面，两个 helper 方法能够自动处理
