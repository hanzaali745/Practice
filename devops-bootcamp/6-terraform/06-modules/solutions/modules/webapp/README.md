# webapp module

Generates config for a web app behind nginx.

```hcl
module "web" {
  source      = "../../modules/webapp"
  name        = "shop"
  environment = "dev"
  replicas    = 2
  out_dir     = "${path.root}/out"
}
```

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | string | — | app name (validated) |
| `environment` | string | — | dev / staging / prod |
| `port` | number | `8000` | first instance port |
| `replicas` | number | `1` | instances behind nginx (1–10) |
| `out_dir` | string | — | output folder |

Outputs: `config_file`, `app_dir`, `ports`.
