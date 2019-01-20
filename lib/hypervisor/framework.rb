require "ffi"

module Hypervisor
  module Framework
    extend FFI::Library

    ffi_lib "/System/Library/Frameworks/Hypervisor.framework/Hypervisor"

    attach_function :valloc, [:size_t], :pointer
    attach_function :free, [:pointer], :void

    attach_function :hv_vm_create, [:uint64_t], :uint
    attach_function :hv_vm_destroy, [], :uint
    attach_function :hv_vm_map, [:pointer, :uint64_t, :size_t, :uint64_t], :uint
    attach_function :hv_vm_unmap, [:uint64_t, :size_t], :uint
    attach_function :hv_vm_protect, [:uint64_t, :size_t, :uint64_t], :uint
    attach_function :hv_vm_sync_tsc, [:uint64_t], :uint

    attach_function :hv_vcpu_create, [:pointer, :uint64_t], :uint
    attach_function :hv_vcpu_destroy, [:uint], :uint
    attach_function :hv_vcpu_read_register, [:uint, :int, :pointer], :uint
    attach_function :hv_vcpu_write_register, [:uint, :int, :uint64_t], :uint
    attach_function :hv_vcpu_read_fpstate, [:uint, :pointer, :size_t], :uint
    attach_function :hv_vcpu_write_fpstate, [:uint, :pointer, :size_t], :uint
    attach_function :hv_vcpu_enable_native_msr, [:uint, :uint32_t, :bool], :uint
    attach_function :hv_vcpu_read_msr, [:uint, :uint32_t, :pointer], :uint
    attach_function :hv_vcpu_write_msr, [:uint, :uint32_t, :uint64_t], :uint
    attach_function :hv_vcpu_flush, [:uint], :uint
    attach_function :hv_vcpu_invalidate_tlb, [:uint], :uint
    attach_function :hv_vcpu_run, [:uint], :uint, blocking: true
    attach_function :hv_vcpu_interrupt, [:pointer, :uint], :uint
    attach_function :hv_vcpu_get_exec_time, [:uint, :pointer], :uint

    attach_function :hv_vmx_vcpu_read_vmcs, [:uint, :uint32_t, :pointer], :uint
    attach_function :hv_vmx_vcpu_write_vmcs, [:uint, :uint32_t, :uint64_t], :uint
    attach_function :hv_vmx_read_capability, [:int, :pointer], :uint
    attach_function :hv_vmx_vcpu_set_apic_address, [:int, :uint64_t], :uint

    def self.return_t(result)
      unless result == 0
        case result
        when SUCCESS
          return
        when ERROR
          raise "Error"
        when BUSY
          raise "Busy"
        when BAD_ARGUMENT
          raise "Bad Argument"
        when NO_RESOURCES
          raise "No Resources"
        when NO_DEVICE
          raise "No Device"
        when UNSUPPORTED
          raise "Hypervisor.framework is not supported on your computer"
        else
          raise "Something went wrong #{result}"
        end
      end
    end
  end
end
