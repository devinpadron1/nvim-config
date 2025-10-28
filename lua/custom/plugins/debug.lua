-- Debugging Support (nvim-dap)
-- Provides GDB integration with visual UI for C++ debugging

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    -- UI components for debugging
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio', -- Required by dap-ui
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    -- Setup DAP UI
    dapui.setup {
      layouts = {
        {
          elements = {
            { id = 'scopes', size = 0.3 }, -- Local variables (auto)
            { id = 'watches', size = 0.2 }, -- Custom watch expressions
            { id = 'breakpoints', size = 0.2 },
            { id = 'stacks', size = 0.3 }, -- Call stack
          },
          size = 40,
          position = 'left',
        },
        {
          elements = {
            { id = 'repl', size = 0.5 },
            { id = 'console', size = 0.5 },
          },
          size = 10,
          position = 'bottom',
        },
      },
    }

    -- Configure GDB adapter for C++ debugging
    dap.adapters.cppdbg = {
      id = 'cppdbg',
      type = 'executable',
      command = '/usr/bin/gdb',
      args = { '-i', 'dap' },
    }

    -- Configure launch configurations (from your launch.json)
    dap.configurations.cpp = {
      {
        name = 'Launch IGS Standalone Plot',
        type = 'cppdbg',
        request = 'launch',
        program = '/home/dpadron2/igs/build-gcc-debug/bin/igs_plot',
        cwd = '/home/dpadron2/igs',
        stopAtEntry = false,
        args = {},
        environment = {
          { name = 'QT_QML_DEBUG', value = '1' },
          { name = 'QML_DISABLE_OPTIMIZER', value = '1' },
        },
      },
      {
        name = 'Launch IGS Standalone Plot (Purge Cache)',
        type = 'cppdbg',
        request = 'launch',
        program = '/home/dpadron2/igs/build-gcc-debug/bin/igs_plot',
        cwd = '/home/dpadron2/igs',
        stopAtEntry = false,
        args = { '--purge-cache', '--qt-settings' },
        environment = {
          { name = 'QT_QML_DEBUG', value = '1' },
          { name = 'QML_DISABLE_OPTIMIZER', value = '1' },
        },
      },
    }

    dap.configurations.qml = dap.configurations.cpp

    -- Auto-open UI when debugging starts (with error handling)
    dap.listeners.after.event_initialized['dapui_config'] = function()
      vim.schedule(function()
        pcall(dapui.open)
      end)
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      pcall(dapui.close)
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      pcall(dapui.close)
    end

    -- Keybindings
    vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<F9>', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'Debug: Step Out' })

    vim.keymap.set('n', '<leader>dr', dap.repl.open, { desc = '[D]ebug: Open [R]EPL' })
    vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = '[D]ebug: Toggle [U]I' })
    vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = '[D]ebug: Toggle [B]reakpoint' })
    vim.keymap.set('n', '<leader>dc', dap.continue, { desc = '[D]ebug: [C]ontinue' })
    vim.keymap.set('n', '<leader>dt', dap.terminate, { desc = '[D]ebug: [T]erminate' })
    vim.keymap.set('n', '<leader>dw', function()
      dapui.elements.watches.add()
    end, { desc = '[D]ebug: Add [W]atch' })
  end,
}
