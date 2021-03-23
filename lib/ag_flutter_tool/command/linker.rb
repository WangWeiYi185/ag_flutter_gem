module Pod
    class Command
      class linker < Command
        # ... 
        self.summary = 'link flutter module'
        self.description = <<-DESC
          'link flutter module form moduel path'
        DESC
        def self.Argument = [
          CLAide::Argument.new('flutter module path'， true， false)，
        ]

        def self.options
            [
              ['--repo-update', 'Force running `pod repo update` before install'],
              ['--deployment', 'Disallow any changes to the Podfile or the Podfile.lock during installation'],
              ['--clean-install', 'Ignore the contents of the project cache and force a full pod installation. This only ' \
                'applies to projects that have enabled incremental installation'],
              ['--build-install', 'Will to be build framework  before link flutter module'], 
          ].concat(super).reject { |(name, _)| name == '--no-repo-update' }

        end

        #arg
        #options 
        #flag --
        def initialize(argv)
            @modulePath = argv.shift_argument
            @build_install = argv.flag?('build-install', false)
            super
            @deployment = argv.flag?('deployment', false)
            @clean_install = argv.flag?('clean-install', false)
        end
            

        def self.run
            $filePath = Dir::pwd

            if !@modulePath 
              @modulePath = $filePath
            end


            if @modulePath == "-h"
              Pod::UI.puts " ❌ \033[31m  [!] Unknown option: `--h` Did you mean: --help \033[0m"
            return 
            end  



            dependencies_array = []
            ### Flutter.framework
            flutterPodNamePath = Dir["#{@modulePath}/.ios/Flutter/engine/*.podspec"][0]
            flutterPodName = File.basename(flutterPodNamePath,".podspec")
            dependencies_array.push({flutterPodName=>[{:path=>"#{@modulePath}/.ios/Flutter/engine/"}]})
    
    
    
            ### app.framework
            appPodNamePath = Dir["#{@modulePath}/.ios/Flutter/*.podspec"][0]
            appPodName = File.basename(appPodNamePath,".podspec")
            dependencies_array.push({appPodName=>[{:path=>"#{@modulePath}/.ios/Flutter/"}]})
    
    
    
            ### FlutterPlugin
            flutterPluginPodNamePath = Dir["#{@modulePath}/.ios/Flutter/FlutterPluginRegistrant/*.podspec"][0]
            flutterPluginPodName = File.basename(flutterPluginPodNamePath,".podspec")
            dependencies_array.push({flutterPluginPodName=>[{:path=>"#{@modulePath}/.ios/Flutter/FlutterPluginRegistrant"}]})
    
    
    
    
            plugin_pods = parse_KV_file(File.join(@modulePath, '.flutter-plugins'))
            plugin_pods.map do |r|
              dependencies_array.push({r[:name]=>[{:path=>"#{r[:path]}/ios/"}]})
            end
    
            UI.puts "🍺 link dependencies begin"
    
            dependencies_array.each do|name, value|
              UI.puts "s.dependency '#{name.keys[0]}'"
            end  
    
            UI.puts "🍺 link dependencies end"
    
    
    
            verify_podfile_exists!
            installer = installer_for_config
            installer.repo_update = repo_update?(:default => false)
            installer.update = false
            installer.deployment = @deployment
            installer.clean_install = @clean_install
            podfile = installer.podfile
    
    
            @config.podfile.dependencies.each do |dependency|
              if dependency.root_name.downcase == name.downcase
                find_dependency = dependency
                break
              end
            end
    
            
            podfile.root_target_definitions.each do |root_target_definition|
              children_definitions = root_target_definition.recursive_children
              children_definitions.each do |children_definition|
                dependencies_hash_array = children_definition.send(:get_hash_value, 'dependencies')
                dependencies_hash_array.concat(dependencies_array)
                children_definition.send(:set_hash_value, 'dependencies', dependencies_hash_array)
              end
    
            end   
    
            installer.install!
            UI.puts "🍺 install success"
        end


        def parse_KV_file(file, separator='=')
          file_abs_path = File.expand_path(file)
          if !File.exists? file_abs_path
            return [];
          end
          pods_array = []
          skip_line_start_symbols = ["#", "/"]
          File.foreach(file_abs_path) { |line|
            next if skip_line_start_symbols.any? { |symbol| line =~ /^\s*#{symbol}/ }
            plugin = line.split(pattern=separator)
            if plugin.length == 2
              podname = plugin[0].strip()
              path = plugin[1].strip()
              podpath = File.expand_path("#{path}", file_abs_path)
              pods_array.push({:name => podname, :path => podpath});
             else
              puts "❌ \033[31m Invalid plugin specification: #{line} \033[0m"
            end
          }
          return pods_array
        end
  
       def build_install()
  
  
        if !File.directory?(@modulePath)
          Pod::UI.puts "❌ \033[31m modulePath not directory: #{@modulePath} \033[0m"
          return  
        end
  
  
        build_res = system "cd #{@modulePath}; curl --request GET --header \'PRIVATE-TOKEN: fuLVCP3nHfPHxdyFYYPc\' https://git.souche-inc.com/api/v4/projects/20571/repository/files/flutter_debug_ios.sh/raw\?ref\=master | bash -"
       
        if !build_res 
          Pod::UI.puts "❌ \033[31m build framework failure: #{@modulePath} \033[0m"
        return 
        end 
  
  
       end

        

    end
  end



    