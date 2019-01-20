require "hypervisor/version"
require "hypervisor/constants"
require "hypervisor/framework"
require "hypervisor/vcpu"

require 'ffi'

module Hypervisor
  def self.allocate(n, &block)
    FFI::AutoPointer.new(Hypervisor::Framework.valloc(n), Hypervisor::Framework.method(:free), &block)
  end

  def self.create(options = VM_DEFAULT)
    Framework.return_t(Framework.hv_vm_create(options))
  end

  def self.destroy
    Framework.return_t(Framework.hv_vm_destroy)
  end

  def self.map(uva, gpa, size, flags)
    Framework.return_t(Framework.hv_vm_map(uva, gpa, size, flags))
  end

  def self.unmap(gpa, size)
    Framework.return_t(Framework.hv_vm_unmap(gpa, size))
  end

  def self.protect(gpa, size, flags)
    Framework.return_t(Framework.hv_vm_protect(gpa, size, flags))
  end

  def self.sync_tsc(tsc)
    Framework.return_t(Framework.hv_vm_sync_tsc(tsc))
  end

  def self.read_capability(field)
    FFI::MemoryPointer.new(:uint64_t, 1) do |value|
      Framework.return_t(Framework.hv_vmx_read_capability(field, value))

      return value.get_uint64(0)
    end
  end
end
