vim9script

if exists('g:loaded_ctrlp_gitbranch')
  finish
endif
g:loaded_ctrlp_gitbranch = 1

command! CtrlPGitBranch {
  ctrlp#init(ctrlp#git_branch#Id())
}