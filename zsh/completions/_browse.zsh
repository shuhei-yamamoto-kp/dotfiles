#compdef browse

# --- ヘルパー関数 ---

# 指定されたオプションの値をコマンドラインから取得する
# 例: _get_opt_value '-project'
_get_opt_value() {
  local option_name=$1
  # `_arguments`が解析した値 (opt_args) から探す
  if [[ -v "opt_args[$option_name]" ]]; then
    echo "${opt_args[$option_name]}"
    return 0
  fi
  # コマンドラインの単語リスト (words) から探す
  # 形式: -option=value
  local value=${${(M)words:#${option_name}=*}#*=}
  if [[ -n "$value" ]]; then
    echo "$value"
    return 0
  fi
  # 形式: -option value
  local idx=${words[(I)$option_name]}
  if (( idx > 0 && idx < $#words )); then
    echo "${words[idx+1]}"
    return 0
  fi
  return 1
}

# --- 値を補完するための関数群 ---

_gcloud_projects() {
  # gcloudコマンドを実行し、結果を行ごとに配列へ格納する
  local -a projects
  projects=("${(@f)$(gcloud projects list --format='value(projectId)' 2>/dev/null)}")
  
  # 配列の中身を補完候補として提示する
  compadd -a projects
}

_gcloud_spanner_instances() {
  # ★★★ 修正箇所 ★★★
  local project=$(_get_opt_value '-project')
  local -a cmd
  cmd=('gcloud' 'spanner' 'instances' 'list' '--format=value(name)')
  # -projectが指定されていればコマンドに追加
  [[ -n "$project" ]] && cmd+=('--project' "$project")
  
  # コマンドを実行し、結果を配列に格納してcompaddで補完
  local -a instances
  instances=("${(@f)$(${cmd[@]} 2>/dev/null)}")
  compadd -a instances
}

_gcloud_spanner_databases() {
  # ★★★ 修正箇所 ★★★
  # -instance オプションの値に依存
  local instance=$(_get_opt_value '-instance')
  if [[ -n "$instance" ]]; then
    local project=$(_get_opt_value '-project')
    local -a cmd
    cmd=('gcloud' 'spanner' 'databases' 'list' '--instance' "$instance" '--format=value(name)')
    [[ -n "$project" ]] && cmd+=('--project' "$project")
    
    # コマンドを実行し、結果を配列に格納してcompaddで補完
    local -a databases
    databases=("${(@f)$(${cmd[@]} 2>/dev/null)}")
    compadd -a databases
  fi
}

_github_orgs() {
  # 実際の組織名に置き換えてください
  _values 'GitHub organization' 'my-org' 'another-org'
}

_github_repos() {
  # -org オプションの値に依存
  local org=$(_get_opt_value '-org')
  # orgに応じてリポジトリを補完 (ここでは例として固定値を設定)
  if [[ "$org" == "my-org" ]]; then
    _values 'GitHub repository' 'my-repo-1' 'my-repo-2'
  else
    # 必要に応じて他の組織のリポジトリ補完ロジックを追加
    _values 'GitHub repository' 'general-repo'
  fi
}

# --- メインの補完関数 ---
_browse() {
  local -a service_opts

  # ★★★ 修正点1: オプション定義のロジックを先に移動 ★★★
  # 現在のコマンドライン入力に基づいて、補完すべきオプションのリストを作成する
  local service=${words[2]}
  local subservice=${words[3]}

  case "$service" in
    gcloud)
      case "$subservice" in
        logs)
          service_opts=(
            '-project:GCP Project:_gcloud_projects'
            '-query:Log query:'
          )
          ;;
        bigquery)
          service_opts=(
            '-project:GCP Project:_gcloud_projects'
          )
          ;;
        spanner)
          service_opts=(
            '-project:GCP Project:_gcloud_projects'
            '-instance:Spanner Instance:_gcloud_spanner_instances'
            '-database:Spanner Database:_gcloud_spanner_databases'
          )
          ;;
      esac
      ;;
    github)
      # githubにはサブサービスがないので、serviceがgithubなら常にこれらのオプションを提示
      service_opts=(
        '-org:GitHub Organization:_github_orgs'
        '-repository:GitHub Repository:_github_repos'
      )
      ;;
  esac

  # ★★★ 修正点2: _argumentsを一度だけ呼び出し、全てを処理させる ★★★
  # state変数とcase文は不要になる
  _arguments -S \
    '1: :_values -S " " "service" "gcloud:Google Cloud Platform services" "github:GitHub services"' \
    '2: :_browse_subservice' \
    "${service_opts[@]}" # ここで動的に作成したオプションのリストを展開
}

# gcloudのサブサービス補完を別の関数に分離
_browse_subservice() {
  case $words[2] in
    gcloud)
      _values -S ' ' "gcloud subservice" \
        "logs:Cloud Logging" \
        "bigquery:BigQuery" \
        "spanner:Cloud Spanner"
      ;;
  esac
}

# browseコマンドに上記の補完関数を割り当て
compdef _browse browse