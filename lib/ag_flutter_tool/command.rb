
require 'claide'
module Pod
    class PlainInformative
      include CLAide::InformativeError
    end
  
    class Command < CLAide::Command
      require 'cocoapods/command/linker'
      require 'cocoapods/command/builder'
      require 'cocoapods/command/cleaner'

      def self.run(argv)
        super.run(argv)

      end
        
    end 