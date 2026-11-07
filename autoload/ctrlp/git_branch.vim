vim9script

if exists('g:loaded_ctrlp_gitbranch_autoload')
  finish
endif
g:loaded_ctrlp_gitbranch_autoload = 1

g:ctrlp_ext_vars = get(g:, 'ctrlp_ext_vars', []) -> add({
  init: 'ctrlp#git_branch#Init()',
  accept: 'ctrlp#git_branch#Accept',
  lname: 'git branches',
  sname: 'gitbranch',
  type: 'line',
  sort: 0,
})

const IndexId = ctrlp#getvar('g:ctrlp_builtins') + len(g:ctrlp_ext_vars)
export def Id(): number
  return IndexId
enddef

const choices = [
  'switch',
  'rename',
  'rebase',
  'createfrom (git switch -c)',
  'yank (clipboard)',
  'delete'
]

export def Init(): list<string>
  return choices
enddef

export def Accept(mode: string, str: string)
  if empty(str)
    return
  endif

  const branch = get(g:, 'ctrlp_gitbranch_branch', '')
  if empty(branch)
    finish
  endif

  ctrlp#exit()
  const choice = substitute(str, '\s.*', '', '')

  if choice ==# 'switch'
    # switch
    execute '!git switch ' .. shellescape(branch)

  elseif choice ==# 'rename'
    # rename
    const new_name = input('New branch name (renaming ' .. branch .. '): ', branch)
    if !empty(new_name) && new_name != branch
      echo "\n"
      execute '!git branch -m ' .. shellescape(branch) .. ' ' .. shellescape(new_name)
    endif

  elseif choice ==# 'rebase'
    # rebase
    execute '!git rebase ' .. shellescape(branch)

  elseif choice ==# 'createfrom'
    # createfrom (git switch -c <new> <target>)
    const new_branch = input('New branch name from ' .. branch .. ': ')
    if !empty(new_branch)
      echo "\n"
      execute '!git switch -c ' .. shellescape(new_branch) .. ' ' .. shellescape(branch)
    endif

  elseif choice ==# 'yank'
    # yank
    setreg('+', branch)
    echo 'Yanked branch: ' .. branch

  elseif choice ==# 'delete'
    # delete
    const confirm = input('Delete branch "' .. branch .. '"? (y/N): ')
    if confirm =~? '^y'
      echo "\n"
      execute '!git branch -d ' .. shellescape(branch)
    else
      echo "\nCanceled deletion."
    endif
  endif
enddef