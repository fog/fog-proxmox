# frozen_string_literal: true

module Fog
  module Compute
    class Proxmox
      # Services class
      class Services
        include Enumerable
        def pve
          yield 'pveproxy'
          yield 'pvedaemon'
          yield 'pvestatd'
          yield 'pve-cluster'
          yield 'pve-firewall'
          yield 'pvefw-logger'
          yield 'pve-ha-crm'
          yield 'pve-ha-lrm'
        end

        def system
          yield 'corosync'
          yield 'spiceproxy'
          yield 'sshd'
          yield 'syslog'
          yield 'cron'
          yield 'postfix'
          yield 'ksmtuned'
          yield 'systemd-timesyncd'
        end
      end
    end
  end
end
