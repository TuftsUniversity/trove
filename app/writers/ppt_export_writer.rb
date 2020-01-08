require 'byebug'
require 'faraday'

class PptExportWriter

  attr_reader :out, :collection

  SLIDE_WIDTH  = 720  # in pixels
  SLIDE_HEIGHT = 540  # in pixels
  SLIDE_ASPECT_RATIO = SLIDE_WIDTH.to_f / SLIDE_HEIGHT.to_f


  def initialize(collection, out, tmpfile)
    @collection = collection
    @out = out
    @tmpfile = tmpfile
  end

  def write
    transmit_collection
    transmit_slides
  end

  private

    def transmit_collection
      # Send the title and metadata for the main title slide
      title_slide = {
        collectionTitle: collection.title.empty? ? "" : collection.title.first,
        description: collection.description.empty? ? [""] : collection.description,
        imageCount: images_with_paths.length, # TODO this is gross here since we're calling a somewhat expensive method again just a little later in the code
        pptExportFile: @tmpfile
      }
      Rails.logger.error(title_slide.to_json)
      out.puts title_slide.to_json
    end

    def transmit_slides
      images_with_paths.each do |image, path|
        transmit_slide(image, path)
      end
    end

    def transmit_slide(pid, path)
      # Send the metadata and file path for each individual image slide
      coords = coordinates(path)

      image = Image.find(pid)

      image_slide = {
          title: image.title.empty? ? "" : image.title.first,
          creator: image.creator.empty? ? [""] : image.creator,
          date: image.primary_date.empty? ? [""] : image.primary_date,
          description: image.description.empty? ? [""] : image.description,
          imagePath: path,
          x: coords[:x],
          y: coords[:y],
          width: coords[:w],
          height: coords[:h]
      }
      Rails.logger.error(image_slide.to_json)
      out.puts image_slide.to_json
    end

    def images_with_paths
      work_order = collection.work_order.empty? ? collection.member_object_ids : collection.work_order

      work_order.flatten.map { |member|
        member_image = Image.find(member)
        file_set = member_image.file_sets[0]
        url = Riiif::Engine.routes.url_helpers.image_url(file_set.files.first.id, host: Rails.configuration.host, port: Rails.configuration.port, protocol: Rails.configuration.protocol, size: "2000,")
        params = { :user_username => Rails.application.secrets.riiif_user, :user_token => Rails.application.secrets.riiif_token }
        uri = URI.parse(url)
        uri.query = URI.encode_www_form( params )
        uri_s = uri.to_s
        base_name = File.basename(uri.path)
        temp_file = Rails.root.join('tmp', 'images', member).to_s

        unless File.file?(temp_file)
          File.open(temp_file, "wb") do |file|
            file.write uri.open.read
          end
        end

        [member,temp_file]

      }.compact
    end

    # Calculate offset, width, & height of the image on the slide
    def coordinates(image_path)
      if image_path.blank?
        return {x:0, y:0, h:0, w:0}
      end

      source_img_width, source_img_height = get_image_dimensions(image_path)
      source_aspect_ratio = source_img_width.to_f / source_img_height.to_f

      if source_aspect_ratio > SLIDE_ASPECT_RATIO
        width = SLIDE_WIDTH
        height = (width / source_aspect_ratio).to_i
      else
        height = SLIDE_HEIGHT
        width = (height * source_aspect_ratio).to_i
      end

      { x: SLIDE_WIDTH / 2 - width / 2,
        y: SLIDE_HEIGHT / 2 - height / 2,
        w: width,
        h: height
      }
    end

    # TODO: Move this into tufts_models gem on the TuftsImage
    # class.  It doesn't really belong here.
    # Something like:  image.dimensions
    def get_image_dimensions(image_path)
      `identify -format %wx%h "#{image_path}"`.split('x').map(&:to_i)
    end

end
