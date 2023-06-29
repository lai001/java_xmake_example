
rule("compiler.java")
    set_extensions(".java")
    on_build_files(function (target, sourcebatch, opt)
        import("lib.detect.find_program")
        local files = target:get("files")
        local args = {}
        if files ~= nil then 
            for _, item in ipairs(files) do
                table.insert(args, item)
            end
        end
        local javac = find_program("javac", {pathes = {"$(env PATH)", function () return "/usr/local/bin" end}})
        os.execv(javac, table.join({ "-sourcepath", target:get("sourcepath"),  "-d", target:objectdir() }, args))
    end)

    on_link(function (target)
        import("lib.detect.find_program")
        os.mkdir(target:targetdir())
        local kind = target:kind()
        local filename = path.join(target:targetdir(), target:basename() .. ".jar")
        local jar = find_program("jar", {pathes = {"$(env PATH)", function () return "/usr/local/bin" end}})
        if kind == "binary" then 
            os.execv(jar, { "-v", "-c", "-f", filename, "--main-class=" .. target:get("mainclass"), "-C", target:objectdir(), "." })  
        else 
            os.execv(jar, { "-v", "-c", "-f", filename, "-C", target:objectdir(), "." })
        end
    end)

target("test")
    add_rules("compiler.java")
    set_kind("binary")
    add_files("src/*.java")
    add_files("src/j/*.java")
    on_config(function (target) 
        target:set("sourcepath", "src")
        target:set("mainclass", "org.lai001.demo.b.B")
    end)
    on_run(function (target)
        local kind = target:kind()
        local filename = path.join(target:targetdir(), target:basename() .. ".jar")
        if kind == "binary" then 
            os.execv("java ", {"-jar", filename})
        end        
    end)