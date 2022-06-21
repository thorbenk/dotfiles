local status_ok, onedark = pcall(require, "onedark")
if not status_ok then
	vim.notify("colorscheme onedark not found!")
	return
end

onedark.setup()

-- vim.cmd([[
-- hi ActiveWindow guibg=#282C34
-- hi InactiveWindow guibg=#191c21
-- set winhighlight=Normal:ActiveWindow,NormalNC:InactiveWindow,LineNr:ActiveWindow
-- ]])

vim.cmd([[
augroup set_jenkins_groovy
au!
au BufNewFile,BufRead *.jenkinsfile,*.Jenkinsfile,Jenkinsfile,jenkinsfile setf groovy
augroup END
]])
