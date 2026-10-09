module Api
  module V1
    class FilesController < BaseController
      skip_before_action :authenticate_user!, only: [:show]

      def upload
        file = params[:file]
        return render_error("No file provided") unless file.present?

        upload_dir = Rails.root.join("storage/uploads")
        FileUtils.mkdir_p(upload_dir)

        ext = File.extname(file.original_filename)
        filename = "#{SecureRandom.uuid}#{ext}"
        target_path = upload_dir.join(filename)

        File.open(target_path, "wb") do |f|
          f.write(file.read)
        end

        json_response(data: {
          url: "/api/v1/files/#{filename}",
          filePath: filename,
          originalName: file.original_filename
        }, message: "File uploaded successfully")
      end

      def show
        filename = params[:file_path]
        file_path = Rails.root.join("storage/uploads", filename)

        if File.exist?(file_path)
          send_file file_path, disposition: 'inline'
        else
          render_error("File not found", status: :not_found)
        end
      end
    end
  end
end
