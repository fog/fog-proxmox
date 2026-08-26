# frozen_string_literal: true

module Fog
  module Proxmox
    class Storage
      # Uploads a local ISO and waits for the Proxmox task to finish.
      class IsoUpload < Fog::Model
        attribute :node_id
        attribute :storage_id
        attribute :path

        def upload
          requires :node_id, :storage_id, :path

          filename = File.basename(path)
          size = File.size(path)
          Fog::Logger.debug("Starting Proxmox ISO upload filename=#{filename} size=#{size} bytes node=#{node_id} storage=#{storage_id}")
          response = File.open(path, 'rb') do |file|
            Fog::Proxmox::Storage.new(service.config).upload_iso(
              { node: node_id, storage: storage_id },
              { filename: filename, file: file }
            )
          end
          Fog::Logger.debug("Upload response: #{response.inspect}")
          raise Fog::Errors::Error, "Unexpected upload response: #{response.inspect}" unless response.to_s.start_with?('UPID:')

          service.nodes.get(node_id).tasks.wait_for(response)
          response
        end
      end
    end
  end
end
