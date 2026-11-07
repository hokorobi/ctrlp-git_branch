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

var IndexId = ctrlp#getvar('g:ctrlp_builtins') + len(g:ctrlp_ext_vars)
export def Id(): number
  return IndexId
enddef

export def Init(): list<string>
  var branches = systemlist(['git', 'branch'])
  if v:shell_error != 0
    echoerr 'Git repository not found or git command failed.'
    return []
  endif
  return branches
enddef

export def Accept(mode: string, str: string)
  if empty(str)
    return
  endif

  ctrlp#exit()
  var branch = substitute(str, '\s*\*\?\s*\|\s\+', '', 'g')

  var choices = [
    '1. switch',
    '2. rename',
    '3. rebase',
    '4. createfrom (git switch -c)',
    '5. yank (clipboard)',
    '6. delete'
  ]
  var choice = inputlist(['Select Action for branch "' .. branch .. '":'] + choices)
  if choice < 1 || choice > len(choices)
    echo "\nCanceled."
    return
  endif

  echo "\n"

  if choice == 1
    # switch
    execute '!git switch ' .. shellescape(branch)

  elseif choice == 2
    # rename
    var new_name = input('New branch name (renaming ' .. branch .. '): ', branch)
    if !empty(new_name) && new_name != branch
      echo "\n"
      execute '!git branch -m ' .. shellescape(branch) .. ' ' .. shellescape(new_name)
    endif

  elseif choice == 3
    # rebase
    execute '!git rebase ' .. shellescape(branch)

  elseif choice == 4
    # createfrom (git switch -c <new> <target>)
    var new_branch = input('New branch name from ' .. branch .. ': ')
    if !empty(new_branch)
      echo "\n"
      execute '!git switch -c ' .. shellescape(new_branch) .. ' ' .. shellescape(branch)
    endif

  elseif choice == 5
    # yank
    setreg('+', branch)
    echo 'Yanked branch: ' .. branch

  elseif choice == 6
    # delete
    var confirm = input('Delete branch "' .. branch .. '"? (y/N): ')
    if confirm =~? '^y'
      echo "\n"
      execute '!git branch -d ' .. shellescape(branch)
    else
      echo "\nCanceled deletion."
    endif
  endif
enddef