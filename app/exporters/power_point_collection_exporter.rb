require 'open3'

class PowerPointCollectionExporter < CollectionExporter
  # TODO: Can/should this be moved to an initializer so that
  # we can parse the config file just once instead of every
  # time we want to generate a powerpoint file?
  def parse_java_config
    config_file = Rails.root.join('config', 'java.yml')
    config_erb = ERB.new(IO.read(config_file)).result(binding)
    Psych.load(config_erb)[Rails.env]
  end

  def pptx_file_name
    export_base_file_name + '.pptx'
  end

  # TODO: Handle the case where there is no data for a field
  def export
    export_file_name = "#{@export_dir}/#{pptx_file_name}"
    f = File.new(export_file_name, 'w').close

    # Open a bi-directional connection to a Java process that
    # will generate the powerpoint file.  Send data to the Java
    # process and receive back either the name of the file that
    # was created or an error message.
    #
    Open3.popen2(java_command) do |stdin, stdout, wait_thr|
      # Send the name of the file we want to create

      PptExportWriter.new(@collection, stdin, export_file_name).write
      # Read back the name of the output file from the Java ppt generator
      output_file = stdout.read

      # TODO:  Error handling
      # We expect output_file == export_file_name.
      # If it's not, something is wrong.
      # If the output_file contains the error_flag instead of
      # the output file name, something went wrong in the Java
      # code.
      # error_flag = /\AERROR:/
    end
    
    File.chmod(0777,export_file_name)
    export_file_name
  end

  private

    def java_command
      "java -cp #{classpath} -Dfile.encoding=UTF-8 -Djava.awt.headless=true Powerpoint"
    end

    def classpath
      poi_files = %w{commons-codec-1.5.jar dom4j-1.6.1.jar gson-2.3.jar poi-ooxml-schemas-3.10.1.jar
                      poi-3.10.1.jar stax-api-1.0.1.jar commons-io-2.4.jar xmlbeans-2.6.0.jar poi-ooxml-3.10.1.jar }

      config = parse_java_config
      jars = poi_files.map {|jar| File.join(config['lib_dir'], jar) }

      cp = jars.join(':')
      ".:#{config['class_files_dir']}:" + cp
    end
end
