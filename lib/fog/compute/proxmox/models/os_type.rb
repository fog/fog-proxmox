# frozen_string_literal: true

module Fog
  module Compute
    class Proxmox
      # Osttype class
      class OsType
        include Enumerable
        def each
          yield 'wxp'
          yield 'w2k'
          yield 'w2k3'
          yield 'w2k8'
          yield 'wvista'
          yield 'win7'
          yield 'win8'
          yield 'win10'
          yield 'l24'
          yield 'l26'
          yield 'solaris'
          yield 'other'
        end
      end
    end
  end
end
