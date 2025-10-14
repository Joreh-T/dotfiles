local W = {}
local home = os.getenv("HOME")

W.workspaces = {
    default_workspace = "default",
    repositories = {
        {
            type = "personal",
            workspace = "default",
            name = "home",
            path = home,
        },
        {
            type = "personal",
            workspace = "dotfiles",
            name = "project",
            path = home .. "/Repositories/personal/gitlab.com/username/dotfiles",
        },
        {
            type = "work",
            workspace = "project",
            name = "project",
            path = home .. "/Repositories/work/gitlab.com/project",
        },
    },
}

return W
