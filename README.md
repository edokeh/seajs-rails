# Sea.js for Rails 3.x

Integrates Sea.js into the Rails 3 Asset Pipeline.

提供一种将 Sea.js 与 Asset Pipeline 结合起来的方式，底层通过 spm-chaos-build 来实现

-----

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

ouput 项其实就是 package.json 中的 spm.output，支持 relative（只合并相对路径）/ all（合并所有路径）两种方式

**新增特性**：relative 配置现在支持这样的写法，即可以增加额外的合并规则

```yaml
output:
  relative:
    - application.js
    - test/a.js:
      - test/a.js
      - test/b.js
      - test/template/*.html.js
    - test/c.js
```

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
* seajs_tag 用于引入 seajs ，并且会根据是否合并引入必要的配置
* seajs_use 用于加载 CMD 模块，支持传递多个模块名称
* 如果需要 use 通用模块（位于 sea-modules 目录下），请在模块名前加上#，如 `<%= seajs_use '#gallery/moment/2.0.0/moment' %>`
* 如果想要使用带 callback 的 use 函数，可使用 seajs_modules 方法，如 `seajs.use(<%= seajs_modules 'blogs/show' %>, function(show){ })`

### 合并

这个 gem 会将 seajs 的打包合并过程嵌入到 assets:precompile 任务中，所以执行这个命令

    $ rake assets:precompile

Sea.js 的合并过程不会与原有的 assets pipeline 冲突，但是请将配置分开

* 需要合并的 CMD 模块文件请在 seajs_config.yml 中配置
* 而非 CMD 模块的文件请依然通过 `config.assets.precompile` 配置

合并完成后，不需要改动页面，两个 helper 方法能够自动处理

**特别注意：**请关注系统的 NODE_PATH 环境变量，如果不配置的话会导致 spm-chaos-build 执行有误


## 参考文章

[Sea.js 如何与 Rails 结合](http://chaoskeh.com/blog/how-to-integrates-seajs-with-rails.html)

## 变动历史

**2014-01-27** `0.0.10`

* 增加对 Rails 4.0 的兼容性支持
* 根据 spm-chaos-build 的新特性，现在支持更细粒度的合并规则配置

**2013-06-13** `0.0.8`

增加 seajs_modules 方法，感谢 @blankyao