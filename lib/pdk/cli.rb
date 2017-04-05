require 'cri'

require 'pdk/cli/util/option_validator'
require 'pdk/cli/util/option_normalizer'
require 'pdk/report'

require 'pdk/cli/new'
require 'pdk/cli/validate'
require 'pdk/cli/test'

module PDK
  module CLI
    def self.base_command
      @base ||= Cri::Command.new.tap do |cmd|
        cmd.modify do
          name 'pdk'
          usage 'pdk command [options]'
          summary 'Puppet SDK'
          description 'The shortest path to better modules.'

          flag :h, :help, 'show help for this command' do |_, c|
            puts c.help
            exit 0
          end

          format_desc = <<-EOS
            Specify desired output format. Valid formats are '#{PDK::Report.formats.join("', '")}'.
            You may also specify a file to which the formatted output will be directed, for example: '--format=junit:report.xml'.
            This option may be specified multiple times as long as each option specifies a distinct target file.
          EOS

          option :f, :format, format_desc, { argument: :required, multiple: true } do |values|
            values.compact.each do |v|
              if v.include?(':')
                format = v.split(':', 2).first

                PDK::CLI::Util::OptionValidator.enum(format, PDK::Report.formats)
              else
                PDK::CLI::Util::OptionValidator.enum(v, PDK::Report.formats)
              end
            end
          end
        end

        cmd.add_command(Cri::Command.new_basic_help)

        cmd.add_command(PDK::CLI::New.command)
        cmd.add_command(PDK::CLI::Validate.command)
        cmd.add_command(PDK::CLI::Test.command)
      end
    end

    def self.run(args)
      base_command.run(args)
    end
  end
end