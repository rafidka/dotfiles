" vim/coc.vim - CoC (Conquer of Completion) configuration

" --- Tab completion ---
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Confirm completion with Enter
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Trigger completion with Ctrl+Space
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" --- Diagnostics navigation ---
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" --- Code navigation ---
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" --- Documentation ---
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight symbol under cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" --- Refactoring ---
nmap <leader>rn <Plug>(coc-rename)
nmap <leader>rf <Plug>(coc-refactor)

" Format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" --- Code actions ---
nmap <leader>ac <Plug>(coc-codeaction-cursor)
nmap <leader>as <Plug>(coc-codeaction-source)
nmap <leader>qf <Plug>(coc-fix-current)

" Apply code action to selected region
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" --- Range selection ---
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" --- Commands ---
command! -nargs=0 Format :call CocActionAsync('format')
command! -nargs=0 OR :call CocActionAsync('runCommand', 'editor.action.organizeImport')
command! -nargs=? Fold :call CocAction('fold', <f-args>)

" --- Status line integration ---
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" --- CocList shortcuts ---
nnoremap <silent><nowait> <leader>ld :<C-u>CocList diagnostics<cr>
nnoremap <silent><nowait> <leader>le :<C-u>CocList extensions<cr>
nnoremap <silent><nowait> <leader>lc :<C-u>CocList commands<cr>
nnoremap <silent><nowait> <leader>lo :<C-u>CocList outline<cr>
nnoremap <silent><nowait> <leader>ls :<C-u>CocList -I symbols<cr>
nnoremap <silent><nowait> <leader>lj :<C-u>CocNext<cr>
nnoremap <silent><nowait> <leader>lk :<C-u>CocPrev<cr>
nnoremap <silent><nowait> <leader>lp :<C-u>CocListResume<cr>
