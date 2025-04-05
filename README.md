# ClickHouse Cluster com HAProxy

Este projeto configura um cluster ClickHouse de alta disponibilidade com 3 nós, 3 instâncias Keeper (ZooKeeper embutido) e um HAProxy para balanceamento de carga, rodando em Docker. Inclui autenticação segura, SSL e restrições de acesso.

## Arquitetura
- **3 Nós ClickHouse**: `ch-node1`, `ch-node2`, `ch-node3` (versão 24.3.5).
- **3 Keepers**: `keeper1`, `keeper2`, `keeper3` para coordenação distribuída.
- **HAProxy**: Balanceia HTTP (`8126`) e TCP (`9003`) com SSL.
- **Clientes**: `ch-client` (CLI), `dbeaver` (GUI) e `tabix` (Web UI).

## Pré-requisitos
- Docker e Docker Compose instalados.
- Windows (ou outro SO compatível com Docker).
- Opcional: Xming ou VcXsrv no Windows para DBeaver GUI.

## Estrutura do Projeto
```
.
C:\Projects\Clickhouse-ReplicatedTable\
├── ch-node1-config\
│   └── config.xml
├── ch-node2-config\
│   └── config.xml
├── ch-node3-config\
│   └── config.xml
├── keeper1-config\
│   └── keeper_config.xml
├── keeper2-config\
│   └── keeper_config.xml
├── keeper3-config\
│   └── keeper_config.xml
├── ssl-certificates\
│   └── haproxy.pem
├── docker-compose.yml
├── haproxy.cfg
└── users.xml  # Aqui está o arquivo comum aos nós
```

## Configuração Inicial

### 1. Clonar o Repositório
Este projeto está hospedado no GitHub. Para começar, clone o repositório para sua máquina local:
```
git clone https://github.com/daniellj/Clickhouse-ReplicatedTable.git
cd Clickhouse-ReplicatedTable
```

### 2. Gerar Certificado SSL
A partir da pasta onde contêm os arquivos do projeto, crie um certificado autoassinado válido por 100 anos:
```
docker run --rm -v "${PWD}:/work" -w /work alpine/openssl req -x509 -newkey rsa:2048 -keyout haproxy.key -out haproxy.crt -days 36500 -nodes -subj "/CN=localhost"
docker run --rm -v "${PWD}:/work" -w /work alpine sh -c "cat haproxy.crt haproxy.key > haproxy.pem"
```

Mova haproxy.pem para ./ssl-certificates/.
```
mv -f haproxy.pem ./ssl-certificates/
```

### 3. Configurar Senhas
Gere hashes SHA256 para os usuários em users.xml:
```
docker run --rm -it clickhouse/clickhouse-server:24.3.5 clickhouse-local --query "SELECT hex(SHA256('admin'))"
```
Observação: os valores em texto puro dentro da query representam a senha de cada usuário.

No arquivo users.xml, insira os valores dos hashes obtidos no comando anterior na chave **password_sha256_hex** de cada usuário:
```
    <admin>
        <password_sha256_hex>YOUR_ADMIN_PASSWORD_HASH</password_sha256_hex>
...
    <service_etl>
        <password_sha256_hex>YOUR_SERVICE_ETL_PASSWORD_HASH</password_sha256_hex>
```

### 4. Permitir que leitura/escrita na pasta que irá armazenar os logs e os dados do Clickhouse
chown -R 101:101 ./data ./log

### 5. Criar a arquitetura
#### Iniciar o Cluster
```
docker compose down --volumes --remove-orphans; docker-compose down;docker compose up --build -d
```

## Conexões
### DBeaver com UI
- **Connected by**: URL
- **Host**: 127.0.0.1
- **Porta**: 8126
- **SSL**: sim, mas em mode = NONE.
- **Usuário**: `admin` (ou outro usuário com acesso)
- **Senha**: Conforme configurado (em texto plano)

### ETLs (TCP)
- **Host**: localhost
- **Porta**: 9003
- **Comando**: ```docker exec -it ch-client clickhouse-client --host localhost --port 9003 --secure --user default --password sua_senha --query "SELECT * FROM system.disks;"```

## Testes
### Tolerância a Falhas:
- Pare um nó: docker stop ch-node1
- Teste conexões em `8126` (HTTP), `9003` (TCP) e `8090` (Tabix). O HAProxy redireciona automaticamente.

### Monitoramento:
- Acesse http://127.0.0.1:8404/stats para status do HAProxy.

## Usuários e Permissões
- admin: Acesso irrestrito, gerenciamento de usuários.
- service_etl: Acesso via haproxy e client, sem limites.
- Perfis:
  - default: 5GB RAM, somente leitura.
  - data_team: 10GB RAM, somente leitura.
  - high_profile: 30GB RAM, escrita permitida.

## Troubleshooting
- Logs: Verifique com docker logs <container_name> (nível trace nos nós).
- SSL: Se o DBeaver ou ETLs falharem, confirme que haproxy.pem está em ./ssl-certificates/.
- Rede: Certifique-se de que todos os serviços estão na rede ch_network.

## Notas de Produção
- Substitua o certificado autoassinado por um Let's Encrypt para uso público.
- Ajuste os timeouts no haproxy.cfg para cargas pesadas.
- Considere mudar o log level para information em produção.
