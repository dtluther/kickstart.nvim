return {
  'ruifm/gitlinker.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' }, -- Required dependency
  config = function()
    require('gitlinker').setup {
      -- Built-in mapping = permalink at the nearest commit that exists on the
      -- remote (upstream tip, else closest pushed ancestor). Moved off
      -- <leader>gy so that can target the default branch (below).
      -- Must be a string, not false: mappings.set() does `mappings or
      -- '<leader>gy'`, so a falsy value re-claims the key we want.
      mappings = '<leader>gY',
    }

    -- Re-set the same key with a desc; the plugin sets none, so which-key
    -- would otherwise label it with the raw <cmd>lua ...<cr> rhs.
    for _, mode in ipairs { 'n', 'v' } do
      vim.keymap.set(mode, '<leader>gY', function()
        require('gitlinker').get_buf_range_url(mode)
      end, { silent = true, desc = 'Copy GitHub link (current branch)' })
    end

    -- Run git under `git_root`; returns (stdout_lines, ok).
    local function gitcmd(git_root, ...)
      local out = vim.fn.systemlist { 'git', '-C', git_root, ... }
      return out, vim.v.shell_error == 0
    end

    -- Tip SHA of the default branch, read from the local remote-tracking ref
    -- (only as fresh as your last fetch). Tries <remote>/HEAD (auto-detects
    -- main vs master etc.), then falls back to common names.
    local function default_branch_sha(git_root, remote)
      for _, ref in ipairs { remote .. '/HEAD', remote .. '/main', remote .. '/master' } do
        local out, ok = gitcmd(git_root, 'rev-parse', ref)
        if ok and out[1] then
          return out[1]
        end
      end
    end

    -- Copy a GitHub link for the current file/range, pinned to the default
    -- branch's tip. Reuses gitlinker's own remote parsing and host callback,
    -- swapping only the rev.
    local function copy_link(mode)
      local git = require 'gitlinker.git'
      local buffer = require 'gitlinker.buffer'
      local hosts = require 'gitlinker.hosts'
      local opts = require('gitlinker.opts').get()

      local git_root = git.get_git_root()
      if not git_root then
        return vim.notify('Not in a git repository', vim.log.levels.ERROR)
      end

      local remote = git.get_branch_remote() or opts.remote
      local repo_data = git.get_repo_data(remote)
      if not repo_data then
        return -- get_repo_data already notified
      end

      local ref = default_branch_sha(git_root, remote)
      if not ref then
        return vim.notify('Could not resolve default branch', vim.log.levels.ERROR)
      end

      local file = buffer.get_relative_path(git_root)
      local range = buffer.get_range(mode, opts.add_current_line_on_normal_mode)

      -- The link points at `ref`, not your buffer. Warn on mismatches that
      -- would make it land wrong: file missing at ref (404), or content drift
      -- (line anchors). Drift check only matters when a line is in the link.
      local _, exists = gitcmd(git_root, 'cat-file', '-e', ref .. ':' .. file)
      if not exists then
        vim.notify(file .. ' is not on the target branch; link may 404', vim.log.levels.WARN)
      elseif range.lstart then
        local _, unchanged = gitcmd(git_root, 'diff', '--quiet', ref, '--', file)
        if not unchanged then
          vim.notify('Line numbers may be off: file differs from target', vim.log.levels.WARN)
        end
      end

      local url_data = vim.tbl_extend('force', repo_data, {
        rev = ref,
        file = file,
        lstart = range.lstart,
        lend = range.lend,
      })

      local callback = hosts.get_matching_callback(url_data.host)
      if not callback then
        return
      end

      local url = callback(url_data)
      if opts.action_callback then
        opts.action_callback(url)
      end
      if opts.print_url then
        vim.notify(url)
      end
    end

    -- <leader>gy -> permalink pinned to the default branch's current tip.
    for _, mode in ipairs { 'n', 'v' } do
      vim.keymap.set(mode, '<leader>gy', function()
        copy_link(mode)
      end, { silent = true, desc = 'Copy GitHub link (default branch tip)' })
    end
  end,
}
