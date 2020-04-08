require 'shellwords'

class PdfCollectionExporter < CollectionExporter
  def pdf_file_name
    export_base_file_name + '.pdf'
  end

  def export
    ppt_file = pptx_exporter.export
    directory = File.dirname(ppt_file)
    Rails.logger.info directory.to_s

    cmd = "#{path_to_libreoffice} --headless --invisible --convert-to pdf --outdir #{directory} #{Shellwords.escape(ppt_file)}"
    Rails.logger.info cmd

    out = `#{cmd} 2>&1` # use backticks so that stdout is captured and not printed
    code = $?
    Rails.logger.info out

    # Delete the old ppt file.
    File.unlink(ppt_file)

    if code.success?
      ppt_file.sub(/pptx\z/, 'pdf')
    else
      raise "There was an error generating the PDF file: #{out}"
    end
  end

  def path_to_libreoffice
    "soffice"
  end

  def pptx_exporter
    @pptx_exporter ||= PowerPointCollectionExporter.new(@collection, @export_dir)
  end
end
