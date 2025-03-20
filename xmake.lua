-- 获取 MSVC 的安装路径（请根据实际安装路径修改）
local msvc_path =
    "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.43.34808"
-- SFML库的地址
local sfml_path = "./external/SFML-3.0.0"

-- 设置项目名称和版本
set_project("TheGame")
set_version("1.0.0")

-- 设置编译模式
add_rules("mode.debug", "mode.release")

-- 设置工具链为 Clang
set_toolchains("clang")

-- 设置 C++ 标准为 C++23
set_languages("c++23")

-- -- 添加 MSVC 标准库的包含路径
add_includedirs(msvc_path .. "/include")

-- -- 添加 MSVC 标准库的库路径
add_linkdirs(msvc_path .. "/lib/x64")

-- 禁用 Clang 默认的标准库，使用 MSVC STL
add_cxxflags("-nostdinc++", "-D_HAS_EXCEPTIONS=1", "-D_ITERATOR_DEBUG_LEVEL=0")

-- 配置SFML库
add_linkdirs(sfml_path .. "/lib")
add_includedirs(sfml_path .. "/include")

-- 构建时自动输出compile_commands.json到build文件夹
add_rules("plugin.compile_commands.autoupdate", {outputdir = "build"})

-- 定义目标
target("Game")
do
    set_kind("binary")
    add_files("src/*.cpp")
    add_links("sfml-system", "sfml-window", "sfml-graphics", "sfml-audio",
              "sfml-network")
    after_build(function(target)
        -- 获取构建输出目录
        local output_dir = target:targetdir()
        -- 定义 SFML 动态链接库文件名
        local dll_files = {
            "sfml-graphics-3.dll", "sfml-window-3.dll", "sfml-system-3.dll",
            "sfml-audio-3.dll", "sfml-network-3.dll"
        }
        -- 复制 DLL 文件到输出目录
        for _, dll in ipairs(dll_files) do
            local src = sfml_path .. "/bin/" .. dll
            local dest = output_dir .. "/" .. dll
            os.cp(src, dest)
        end
    end)
    after_clean(function (target)
        local output_dir = target:targetdir()
        os.rm(output_dir .. "/*")
    end)
end
