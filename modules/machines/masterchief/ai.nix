{
  # ollama is built against CUDA, and so is sunshine. Neither is in
  # cache.nixos.org, and without this cache both compile from source for
  # hours. It is declared on the flake rather than only on this host so that
  # `nix flake check --accept-flake-config` gets it on any machine.
  flake-file.nixConfig = {
    extra-substituters = ["https://cache.nixos-cuda.org"];
    extra-trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };

  flake.modules.nixos.masterchiefAi = {
    config,
    pkgs,
    ...
  }: {
    sops.secrets = {
      "searx/secret_key".sopsFile = ./secrets.yaml;
      "litellm/gemini_api_key".sopsFile = ./secrets.yaml;
      "litellm/groq_api_key".sopsFile = ./secrets.yaml;
      "litellm/openrouter_api_key".sopsFile = ./secrets.yaml;
      "litellm/cerebras_api_key".sopsFile = ./secrets.yaml;
      "litellm/mistral_api_key".sopsFile = ./secrets.yaml;
      "litellm/github_token".sopsFile = ./secrets.yaml;
      "litellm/litellm_master_key".sopsFile = ./secrets.yaml;
      "openwebui/admin_email".sopsFile = ./secrets.yaml;
      "openwebui/admin_password".sopsFile = ./secrets.yaml;
    };

    sops.templates."litellm.env" = {
      content = ''
        GEMINI_API_KEY=${config.sops.placeholder."litellm/gemini_api_key"}
        GROQ_API_KEY=${config.sops.placeholder."litellm/groq_api_key"}
        OPENROUTER_API_KEY=${config.sops.placeholder."litellm/openrouter_api_key"}
        CEREBRAS_API_KEY=${config.sops.placeholder."litellm/cerebras_api_key"}
        MISTRAL_API_KEY=${config.sops.placeholder."litellm/mistral_api_key"}
        GITHUB_TOKEN=${config.sops.placeholder."litellm/github_token"}
        LITELLM_MASTER_KEY=${config.sops.placeholder."litellm/litellm_master_key"}
      '';
      owner = "litellm";
      group = "litellm";
    };

    users.users.litellm = {
      isSystemUser = true;
      group = "litellm";
    };
    users.groups.litellm = {};

    services.litellm = {
      enable = true;
      port = 4000;

      # Loopback only: Open WebUI on this machine is the one client. This was
      # the pfSense-era LAN address, which this machine no longer has, so
      # binding it failed with "cannot assign requested address".
      host = "127.0.0.1";

      # Point to the sops-rendered env file
      environmentFile = config.sops.templates."litellm.env".path;

      settings = {
        model_list = [
          # ── Local Ollama Models (Last Resort) ───────────────────────
          {
            model_name = "ollama-qwen-coder";
            litellm_params = {
              model = "ollama/qwen3.5-coder:7b";
              api_base = "http://localhost:11434";
            };
          }
          {
            model_name = "ollama-qwen-general";
            litellm_params = {
              model = "ollama/qwen3.5:9b";
              api_base = "http://localhost:11434";
            };
          }
          {
            model_name = "ollama-deepseek";
            litellm_params = {
              model = "ollama/deepseek-r1:8b";
              api_base = "http://localhost:11434";
            };
          }
          {
            model_name = "ollama-phi-fast";
            litellm_params = {
              model = "ollama/phi4:mini";
              api_base = "http://localhost:11434";
            };
          }

          # Gemini
          {
            model_name = "gemini-flash-2.5";
            litellm_params = {
              model = "gemini/gemini-2.5-flash";
              api_key = "os.environ/GEMINI_API_KEY";
              rpm = 10;
              tpm = 250000;
            };
          }
          {
            model_name = "gemini-flash-3";
            litellm_params = {
              model = "gemini/gemini-3-flash-preview";
              api_key = "os.environ/GEMINI_API_KEY";
              rpm = 5;
              tpm = 250000;
            };
          }
          {
            model_name = "gemini-flash-lite-3.1";
            litellm_params = {
              model = "gemini/gemini-3.1-flash-lite";
              api_key = "os.environ/GEMINI_API_KEY";
              rpm = 15;
              tpm = 250000;
            };
          }
          {
            model_name = "gemini-flash-lite-2.5";
            litellm_params = {
              model = "gemini/gemini-2.5-flash-lite";
              api_key = "os.environ/GEMINI_API_KEY";
              rpm = 15;
              tpm = 250000;
            };
          }

          # Groq
          {
            model_name = "groq-llama-3.1-8b";
            litellm_params = {
              model = "groq/llama-3.1-8b-instant";
              api_key = "os.environ/GROQ_API_KEY";
              rpm = 30;
              tpm = 6000;
            };
          }
          {
            model_name = "groq-llama-3.3-70b";
            litellm_params = {
              model = "groq/llama-3.3-70b-versatile";
              api_key = "os.environ/GROQ_API_KEY";
              rpm = 30;
              tpm = 12000;
            };
          }
          {
            model_name = "groq-llama-4-scout";
            litellm_params = {
              model = "groq/meta-llama/llama-4-scout-17b-16e-instruct";
              api_key = "os.environ/GROQ_API_KEY";
              rpm = 30;
              tpm = 30000;
            };
          }
          {
            model_name = "groq-kimi-k2";
            litellm_params = {
              model = "groq/moonshotai/kimi-k2-instruct";
              api_key = "os.environ/GROQ_API_KEY";
              rpm = 60;
              tpm = 10000;
            };
          }

          # Cerebras
          {
            model_name = "cerebras-llama-3.1-8b";
            litellm_params = {
              model = "cerebras/llama3.1-8b";
              api_key = "os.environ/CEREBRAS_API_KEY";
              rpm = 30;
              tpm = 60000;
            };
          }
          {
            model_name = "cerebras-qwen3-235b";
            litellm_params = {
              model = "cerebras/qwen-3-235b-a22b-instruct-2507";
              api_key = "os.environ/CEREBRAS_API_KEY";
              rpm = 30;
              tpm = 60000;
            };
          }

          # Mistral
          {
            model_name = "mistral-codestral";
            litellm_params = {
              model = "mistral/codestral-latest";
              api_key = "os.environ/MISTRAL_API_KEY";
              rpm = 2;
              tpm = 500000;
            };
          }
          {
            model_name = "mistral-small";
            litellm_params = {
              model = "mistral/mistral-small-latest";
              api_key = "os.environ/MISTRAL_API_KEY";
              rpm = 2;
              tpm = 500000;
            };
          }
          {
            model_name = "mistral-large";
            litellm_params = {
              model = "mistral/mistral-large-latest";
              api_key = "os.environ/MISTRAL_API_KEY";
              rpm = 2;
              tpm = 500000;
            };
          }
          {
            model_name = "mistral-nemo";
            litellm_params = {
              model = "mistral/open-mistral-nemo";
              api_key = "os.environ/MISTRAL_API_KEY";
              rpm = 2;
              tpm = 500000;
            };
          }

          # OpenRouter (Free models)
          {
            model_name = "openrouter-gpt-oss-120b";
            litellm_params = {
              model = "openrouter/openai/gpt-oss-120b:free";
              api_key = "os.environ/OPENROUTER_API_KEY";
              rpm = 20;
            };
          }
          {
            model_name = "openrouter-qwen3.6-plus";
            litellm_params = {
              model = "openrouter/qwen/qwen3.6-plus:free";
              api_key = "os.environ/OPENROUTER_API_KEY";
              rpm = 20;
            };
          }
          {
            model_name = "openrouter-nvidia-nemotron-super";
            litellm_params = {
              model = "openrouter/nvidia/nemotron-3-super-120b-a12b:free";
              api_key = "os.environ/OPENROUTER_API_KEY";
              rpm = 20;
            };
          }

          # GitHub Models
          {
            model_name = "github-gpt-4.1";
            litellm_params = {
              model = "openai/gpt-4.1";
              api_key = "os.environ/GITHUB_TOKEN";
              api_base = "https://models.github.ai/inference";
              rpm = 10;
            };
          }
          {
            model_name = "github-deepseek-r1";
            litellm_params = {
              model = "openai/DeepSeek-R1";
              api_key = "os.environ/GITHUB_TOKEN";
              api_base = "https://models.github.ai/inference";
              rpm = 10;
            };
          }
          {
            model_name = "github-llama-3.3-70b";
            litellm_params = {
              model = "openai/Meta-Llama-3.3-70B-Instruct";
              api_key = "os.environ/GITHUB_TOKEN";
              api_base = "https://models.github.ai/inference";
              rpm = 15;
            };
          }
          {
            model_name = "github-phi-4";
            litellm_params = {
              model = "openai/Phi-4";
              api_key = "os.environ/GITHUB_TOKEN";
              api_base = "https://models.github.ai/inference";
              rpm = 15;
            };
          }

          # ── Virtual Models for Continue.dev ─────────────────────────────
          {
            model_name = "fast-auto";
            litellm_params = {model = "groq-llama-3.1-8b";};
          }
          {
            model_name = "chat-auto";
            litellm_params = {model = "gemini-flash-lite-3.1";};
          }
          {
            model_name = "coding-auto";
            litellm_params = {model = "mistral-codestral";};
          }
        ];

        # Local-only fallbacks (prioritized: fastest → best quality)
        router_settings = {
          fallbacks = [
            # ── Virtual Models (Cloud first → Local last) ─────────────────────
            {"coding-auto" = ["mistral-codestral" "ollama-qwen-coder"];}
            {"chat-auto" = ["gemini-flash-lite-3.1" "ollama-qwen-general"];}
            {"fast-auto" = ["groq-llama-3.1-8b" "groq-llama-4-scout" "mistral-small" "gemini-flash-lite-3.1" "ollama-phi-fast"];}

            # ── Fast-Auto Chain (full trickle-down) ───────────────────────
            {"groq-llama-3.1-8b" = ["groq-llama-4-scout" "mistral-small" "gemini-flash-lite-3.1" "ollama-phi-fast"];}
            # ── Fast-Auto Chain (full trickle-down) ───────────────────────
            {"groq-llama-3.1-8b" = ["groq-llama-4-scout" "mistral-small" "gemini-flash-lite-3.1" "ollama-phi-fast"];}
            {"groq-llama-4-scout" = ["mistral-small" "gemini-flash-lite-3.1" "ollama-phi-fast"];}
            {"mistral-small" = ["gemini-flash-lite-3.1" "ollama-phi-fast"];}
            {"gemini-flash-lite-3.1" = ["ollama-phi-fast"];}

            # ── Coding Chain ──────────────────────────────────────────────────
            {"mistral-codestral" = ["cerebras-qwen3-235b" "groq-qwen3-32b" "groq-gpt-oss-120b" "groq-kimi-k2" "gemini-flash-3" "gemini-flash-2.5" "openrouter-gpt-oss-120b" "ollama-qwen-coder"];}
            {"cerebras-qwen3-235b" = ["groq-qwen3-32b" "groq-gpt-oss-120b" "groq-kimi-k2" "gemini-flash-3" "gemini-flash-2.5" "openrouter-gpt-oss-120b" "ollama-qwen-coder"];}
            {"groq-qwen3-32b" = ["groq-gpt-oss-120b" "groq-kimi-k2" "gemini-flash-3" "gemini-flash-2.5" "openrouter-gpt-oss-120b" "ollama-qwen-coder"];}
            {"groq-gpt-oss-120b" = ["groq-kimi-k2" "gemini-flash-3" "gemini-flash-2.5" "openrouter-gpt-oss-120b" "ollama-qwen-coder"];}
            {"groq-kimi-k2" = ["gemini-flash-3" "gemini-flash-2.5" "openrouter-gpt-oss-120b" "ollama-qwen-coder"];}
            {"gemini-flash-3" = ["gemini-flash-2.5" "openrouter-gpt-oss-120b" "ollama-qwen-coder"];}
            {"gemini-flash-2.5" = ["openrouter-gpt-oss-120b" "ollama-qwen-coder"];}
            {"openrouter-gpt-oss-120b" = ["ollama-qwen-coder"];}

            # ── General Chat Chain ────────────────────────────────────────────
            {"gemini-flash-lite-3.1" = ["gemini-flash-lite-2.5" "groq-llama-3.3-70b" "groq-llama-4-scout" "groq-kimi-k2" "cerebras-llama-3.1-8b" "openrouter-nvidia-nemotron-super" "ollama-qwen-general"];}
            {"gemini-flash-lite-2.5" = ["groq-llama-3.3-70b" "groq-llama-4-scout" "groq-kimi-k2" "cerebras-llama-3.1-8b" "openrouter-nvidia-nemotron-super" "ollama-qwen-general"];}
            {"groq-llama-3.3-70b" = ["groq-llama-4-scout" "groq-kimi-k2" "cerebras-llama-3.1-8b" "openrouter-nvidia-nemotron-super" "ollama-qwen-general"];}
            {"groq-llama-4-scout" = ["groq-kimi-k2" "cerebras-llama-3.1-8b" "openrouter-nvidia-nemotron-super" "ollama-qwen-general"];}
            {"groq-kimi-k2" = ["cerebras-llama-3.1-8b" "openrouter-nvidia-nemotron-super" "ollama-qwen-general"];}
            {"cerebras-llama-3.1-8b" = ["openrouter-nvidia-nemotron-super" "ollama-qwen-general"];}
            {"openrouter-nvidia-nemotron-super" = ["ollama-qwen-general"];}
          ];
          num_retries = 2;
          allowed_fails = 1;
          cooldown_time = 300;
          retry_policy = {
            RateLimitErrorRetries = 1;
            ServiceUnavailableErrorRetries = 1;
          };
          optional_pre_call_checks = ["enforce_model_rate_limits"];
        };

        general_settings = {
          master_key = "os.environ/LITELLM_MASTER_KEY";
        };

        litellm_settings = {
          drop_params = true;
          set_verbose = true;
          num_retries = 2;
        };
      };
    };

    services.ollama = {
      enable = true;
      host = "0.0.0.0";
      package = pkgs.ollama-cuda;
      loadModels = [
        "qwen2.5-coder:7b"
        "qwen3.5:9b"
        "qwen3:8b"
        "deepseek-r1:8b"
      ];
    };

    sops.templates."openwebui.env" = {
      content = ''
        OPENAI_API_KEY=${config.sops.placeholder."litellm/litellm_master_key"}
        WEBUI_ADMIN_EMAIL=${config.sops.placeholder."openwebui/admin_email"}
        WEBUI_ADMIN_PASSWORD=${config.sops.placeholder."openwebui/admin_password"}
      '';
      owner = "open-webui"; # or whatever user runs the service
      group = "open-webui"; # or whatever user runs the service
    };

    users.users.open-webui = {
      isSystemUser = true;
      group = "open-webui";
    };
    users.groups.open-webui = {};

    services.open-webui = {
      enable = true;
      port = 8080;
      host = "0.0.0.0";
      environmentFile = config.sops.templates."openwebui.env".path;
      environment = {
        ENABLE_OLLAMA_API = "false";
        OPENAI_API_BASE_URL = "http://127.0.0.1:4000/v1";
        WEBUI_NAME = "My AI";
        ENABLE_SIGNUP = "false";
        DEFAULT_USER_ROLE = "admin";
        #DEFAULT_MODELS = "groq-llama,gemini-pro";
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
      };
    };

    sops.templates."searx.env" = {
      content = ''
        SEARXNG_SECRET=${config.sops.placeholder."searx/secret_key"}
      '';
      owner = "searx";
      group = "searx";
    };

    users.users.searx = {
      isSystemUser = true;
      group = "searx";
    };
    users.groups.searx = {};

    services.searx = {
      enable = true;
      package = pkgs.searxng;
      redisCreateLocally = true;
      environmentFile = config.sops.templates."searx.env".path;
      settings = {
        general.debug = false;

        server = {
          bind_address = "localhost";
          port = 8888;
          limiter = false;
          method = "GET";
        };

        search.formats = ["html" "json"];
      };
    };
  };
}
