module Hypervisor
  class VCPU
    def initialize(flags = VCPU_DEFAULT)
      FFI::MemoryPointer.new(:uint, 1) do |vcpu|
        Framework.return_t(Framework.hv_vcpu_create(vcpu, flags))

        @vcpu = vcpu.get_uint(0)
      end
    end

    def destroy!
      Framework.return_t(Framework.hv_vcpu_destroy(@vcpu))
    end

    def flush
      Framework.return_t(Framework.hv_vcpu_flush(@vcpu))
    end

    def invalidate_tlb
      Framework.return_t(Framework.hv_vcpu_invalidate_tlb(@vcpu))
    end

    def run
      Framework.return_t(Framework.hv_vcpu_run(@vcpu))
    end

    def read_register(register)
      FFI::MemoryPointer.new(:uint64_t, 1) do |value|
        Framework.return_t(Framework.hv_vcpu_read_register(@vcpu, register, value))

        return value.get_uint64(0)
      end
    end

    def write_register(register, value)
      Framework.return_t(Framework.hv_vcpu_write_register(@vcpu, register, value))
    end

    def read_vmcs(field)
      FFI::MemoryPointer.new(:uint64_t, 1) do |value|
        Framework.return_t(Framework.hv_vmx_vcpu_read_vmcs(@vcpu, field, value))

        return value.get_uint64(0)
      end
    end

    def write_vmcs(field, value)
      Framework.return_t(Framework.hv_vmx_vcpu_write_vmcs(@vcpu, field, value))
    end

    # Helpers

    [:a, :b, :c, :d].each do |register|
      const = Hypervisor.const_get("X86_R#{register.upcase}X")

      define_method("r#{register}x") do
        read_register(const)
      end

      define_method("r#{register}x=") do |value|
        write_register(const, value)
      end

      define_method("e#{register}x") do
        read_register(const) & 0xffffffff
      end

      define_method("e#{register}x=") do |value|
        write_register(const, value & 0xffffffff)
      end

      define_method("#{register}x") do
        read_register(const) & 0xffff
      end

      define_method("#{register}x=") do |value|
        write_register(const, value & 0xffff)
      end

      define_method("#{register}l") do
        read_register(const) & 0xff
      end

      define_method("#{register}l=") do |value|
        old = read_register(const) & 0xff00

        write_register(const, old | (value & 0xff))
      end

      define_method("#{register}h") do
        (read_register(const) & 0xff00) >> 8
      end

      define_method("#{register}h=") do |value|
        old = read_register(const) & 0xff

        write_register(const, old | ((value & 0xff) << 8))
      end
    end
    
    [:cs, :ss, :ds, :es, :fs, :gs].each do |register|
      const = Hypervisor.const_get("X86_#{register.upcase}")

      define_method(register) do
        read_register(const)
      end

      define_method("#{register}=") do |value|
        write_register(const, value)
      end
    end

    def flags
      read_register(Hypervisor::X86_RFLAGS)
    end

    def flags=(value)
      write_register(Hypervisor::X86_RFLAGS, value)
    end

    { cf: 0, pf: 2, af: 4, zf: 6, sf: 7, tf: 8, if: 9, df: 10, of: 11, rf: 16, vm: 17, ac: 18, vif: 19, vip: 20, id: 21 }.each do |register, offset|
      define_method(register) do
        flags[offset]
      end

      mask = (1 << offset)

      define_method("#{register}=") do |value|
        old = flags & ~mask

        if value == 0
          write_register(Hypervisor::X86_RFLAGS, old)
        else
          write_register(Hypervisor::X86_RFLAGS, old | mask)
        end
      end
    end
  end
end
