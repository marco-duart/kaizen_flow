# 🚀 KaizenFlow Backend - Planejamento Completo

O **KaizenFlow** é um sistema de gerenciamento de tickets focado em **Governança de TI** para ambientes educacionais (faculdades e escolas), com funcionalidades de controle de estoque e alta capacidade de customização. O backend será construído utilizando **Ruby on Rails** para fornecer uma API robusta e escalável.

---

## 1. 📐 Estrutura de Modelos, Relações e Atributos (Schema Detalhado)

A estrutura abaixo garante a **customização**, **escalabilidade** e o controle granular de **permissões** e **inventário**.

### A. Governança e Estrutura

| Modelo | Atributos Chave | Relações Principais | Notas |
| :--- | :--- | :--- | :--- |
| **Company** | `name` (string), `cnpj` (string), `active` (boolean) | `has_many :units` | Entidade raiz. |
| **Unit** | `name` (string), `address` (string), **`company_id` (FK)** | `belongs_to :company`, `has_many :networks`, `has_many :rooms`, `has_many :tickets` | Representa as filiais/unidades. |
| **Network** | `name` (string), **`unit_id` (FK)** | `belongs_to :unit` | Classificações de rede (Admin, Acadêmica). |
| **Room** | `name` (string), `location_type` (enum), **`unit_id` (FK)** | `belongs_to :unit`, `has_many :devices`, `has_and_belongs_to_many :groups` | Local de abertura de ticket/ativo. |
| **Group** | `name` (string), `description` (text) | `has_and_belongs_to_many :rooms`, `has_and_belongs_to_many :users` | Usado para controlar acesso a tecnologias específicas. |

### B. Usuário e Permissão (Customizável)

| Modelo | Atributos Chave | Relações Principais | Notas |
| :--- | :--- | :--- | :--- |
| **User** | `email` (string, unique), `password_digest` (string), `full_name` (string), **`is_online` (boolean)**, **`role_id` (FK)**, **`department_id` (FK)** | `belongs_to :role`, `belongs_to :department`, `has_and_belongs_to_many :groups` | Ativação do **chat** via `is_online` (Action Cable). |
| **Role** | `name` (string, unique) | `has_many :users`, `has_many :permissions` | Perfis base (Admin, Agente, Usuário Final, Supervisor). |
| **Permission** | `resource` (string), `action` (string), `level` (string) | `belongs_to :role` | **Permissão Granular Customizável:** Ex: `{resource: 'ticket', action: 'view', level: 'own_department'}`. |
| **Department** | `name` (string) | `has_many :users`, `has_many :teams` | Escalável para além da TI (RH, Eventos). |
| **Team** | `name` (string), **`department_id` (FK)** | `belongs_to :department`, `has_and_belongs_to_many :users` (Agentes) | Usado para atribuição de tickets. |

### C. Ticket (Core)

| Modelo | Atributos Chave | Relações Principais | Notas |
| :--- | :--- | :--- | :--- |
| **Ticket** | `subject` (string), `description` (text), **`custom_data` (JSONB)**, **`requester_id` (FK)**, **`assignee_id` (FK)**, **`category_id` (FK)**, **`status_id` (FK)**, **`priority_id` (FK)**, **`unit_id` (FK)**, **`room_id` (FK)** | `belongs_to :requester`, `belongs_to :assignee`, `belongs_to :category`, `has_many :comments`, `has_many :tasks`, `has_many :ticket_links` | `custom_data` para campos dinâmicos no formulário. |
| **TicketCustomField** | `name` (string), `field_type` (enum), `is_required` (boolean), **`ticket_category_id` (FK)** | `belongs_to :ticket_category` | Define campos obrigatórios e opcionais. |
| **TicketSchedule** | `frequency` (enum), `start_date` (date), `template_ticket_data` (jsonb) | `has_many :tickets` (gerados) | Para tickets **recorrentes** e automação de tarefas fixas. |
| **TicketLink** | **`blocking_ticket_id` (FK)**, **`blocked_ticket_id` (FK)**, `link_type` (enum: 'impediment', 'related') | Cria a relação de bloqueio/impedimento. |
| **Comment** | `content` (text), **`is_internal` (boolean)**, **`ticket_id` (FK)**, **`user_id` (FK)** | `belongs_to :ticket`, `has_one :attachment` | Controla visibilidade de chat (técnico/usuário). |
| **Attachment** | `file_data` (ActiveStorage), **`attachable_type/id` (Polimórfico)** | `belongs_to :attachable` (Ticket ou Comment) | Permite anexos em comentários e no ticket. |
| **TicketHistory** | `action` (string), `details` (jsonb), **`ticket_id` (FK)**, **`user_id` (FK)** | `belongs_to :ticket` | Histórico de auditoria, oculto para o usuário final. |
| **SLA** | `name` (string), **`target_resolution_time_minutes` (integer)**, **`ticket_category_id` (FK)** | `belongs_to :ticket_category` | Prazos **editáveis pela gestão**. |
| **SatisfactionSurvey**| `rating` (integer), `comment` (text), **`ticket_id` (FK)** | `belongs_to :ticket` | |

### D. Inventário e Estoque (Stock)

| Modelo | Atributos Chave | Relações Principais | Notas |
| :--- | :--- | :--- | :--- |
| **Item** | **`sku` (string, unique)**, `name` (string), **`reorder_point` (integer)**, **`category_attributes` (JSONB)**, **`category_id` (FK)** | `belongs_to :category`, `has_many :stock_records`, `has_many :devices` (como componente) | Otimizado para controle de insumos e hardware. |
| **Device** | **`asset_tag` (string, unique)**, `serial_number` (string), **`user_id` (FK)** (dono), **`room_id` (FK)** (localização) | `belongs_to :user`, `belongs_to :room`, `has_many :items` (componentes) | Ativo físico. |
| **StockRecord** | `movement_type` (enum), `quantity` (integer), **`item_id` (FK)**, **`user_id` (FK)** (responsável) | `belongs_to :item` | Rastreamento de movimentação. |
| **Loan** | **`due_date` (date)**, **`loanable_type/id` (Polimórfico)**, **`user_id` (FK)** | `belongs_to :loanable` (Item ou Device) | Controle de empréstimos com data limite. |

### E. Customização (Configuração)

| Modelo | Atributos Chave | Relações Principais | Notas |
| :--- | :--- | :--- | :--- |
| **TicketCategory** | `name` (string), `description` (text), **`parent_id` (FK)** | `belongs_to :parent` (opcional), `has_many :children` | Suporte a Categorias e Subcategorias. |
| **TicketStatus** | `name` (string, unique), `is_final` (boolean), `is_closed` (boolean) | `has_many :tickets` | Totalmente customizável. |
| **TicketPriority** | `name` (string, unique), `level` (integer) | `has_many :tickets` | Totalmente customizável. |

---

## 2. 📝 Casos de Uso Abrangentes

Os casos de uso descrevem as interações essenciais, mantendo a simplicidade e a abrangência.

### A. Gestão de Chamados (Ticket Lifecycle)

| Caso de Uso | Usuários Principais | Descrição |
| :--- | :--- | :--- |
| **Abrir Ticket** | Usuário Final, Agente | O usuário envia o chamado preenchendo **campos obrigatórios** (Assunto, Descrição, Local, Departamento). O sistema notifica agentes. |
| **Atribuição Inteligente** | Agente, Sistema | O sistema utiliza um **algoritmo de distribuição** (Service Object) para atribuir o ticket ao agente mais **ocioso**, com opção de reatribuição manual. |
| **Comunicação (Chat)** | Todos | Usuários e Agentes trocam **Comments** em tempo real (via Action Cable). Agentes podem adicionar `Comentários Internos` (`is_internal: true`). |
| **Controle de Fluxo** | Agente | Agente atualiza o **Status** (customizável), adiciona **Tarefas/Checklists** e anexa arquivos (imagens, PDF). |
| **Bloqueio por Impedimento**| Agente | Agente cria um **TicketLink** do tipo 'impediment' para um segundo ticket ou evento, paralisando o chamado e alterando seu status. |
| **Aprovação** | Gerente/Supervisor | Um ticket que requer recursos ou permissão entra em fluxo de **aprovação** antes de ser movido para 'Em Atendimento'. |
| **Monitoramento SLA** | Agente, Gerente | O sistema exibe o **SLA** restante e gera notificações automáticas quando o prazo está próximo. |
| **Fechamento e Pesquisa** | Agente, Usuário Final | Após a resolução, o ticket é **Finalizado/Fechado** e o sistema envia a **SatisfactionSurvey** ao requisitante. |
| **Reabertura** | Equipe de TI | Qualquer membro da Equipe de TI pode reabrir um ticket fechado, retornando-o ao fluxo. |

### B. Governança e Automação

| Caso de Uso | Usuários Principais | Descrição |
| :--- | :--- | :--- |
| **Agendamento Recorrente**| Admin/Agente | Criação de **TicketSchedule** para gerar chamados automaticamente em datas fixas (Ex: Verificação de Hardware, Inventário Semanal). |
| **Gestão de Roles e Permissions**| Admin | Criação e edição de **Roles** (cargos) e configuração **granular** das **Permissions** (view, edit, delegate) para cada recurso. |
| **Customização Global** | Admin | Criação de **Categorias, Status** e **Prioridades** customizadas. Definição de **SLA** por Categoria. |
| **Relatórios e Dashboard** | Gerente, Admin | Visualização de métricas chave (MTTR, Volume, Satisfação) e **exportação** de dados (Excel/PDF). |

### C. Inventário e Dispositivos

| Caso de Uso | Usuários Principais | Descrição |
| :--- | :--- | :--- |
| **Gestão de Ativos** | Agente | Cadastro e edição de **Devices** e **Items** (com SKU, MPN, Custo, Ponto de Reposição). |
| **Controle de Localização** | Agente | Vincula **Devices** e **Items** à **Rooms** (Salas) e a **Users** (Dono Principal). |
| **Empréstimo** | Agente | Registro de **Loan** de um Item/Device com data limite (`due_date`) e notificação de devolução. |
| **Movimentação de Estoque** | Agente | Registro de entrada, saída e consumo de **Items** (`StockRecord`). |

---

## 3. 🛠️ Tecnologias, Gems e Estratégias

As escolhas tecnológicas são focadas em segurança, customização extrema e escalabilidade.

| Categoria | Item | Descrição e Estratégia |
| :--- | :--- | :--- |
| **Framework** | **Ruby on Rails (API)** | Backend RESTful API para desacoplamento total do Front-end. |
| **Gems de Autenticação** | **`devise`**, **`devise_token_auth`** | Autenticação segura via Token (essencial para API) e gerenciamento de usuários. |
| **Gem de Autorização** | **`pundit`** | Implementação das **Permissions** customizáveis. **Pundit** permite políticas de acesso claras e manuteníveis. |
| **Comunicação Real-Time**| **Action Cable** | Utilizado para o **chat** (Comment Model), notificações instantâneas (pop-up) de novos tickets e rastreamento de **usuários online** (`User.is_online`). |
| **Gem de Uploads** | **`activestorage`** | Gerenciamento de anexos de arquivos (sem limites de tipo - PDF, PNG, JPEG, etc.). |
| **Gem de Configuração** | **`dotenv-rails`** | Gerenciamento seguro das variáveis de ambiente de produção e desenvolvimento. |
| **Estratégia de Customização**| **JSONB Fields (PostgreSQL)** | Estratégia para armazenar dados dinâmicos (`Ticket.custom_data`, `Item.category_attributes`) sem alterar o schema do banco a cada nova customização de campo. |
| **Padrão de Design**| **Service Objects** | Uso para encapsular regras complexas, como a **atribuição automática** e a lógica de **TicketSchedule**. |
| **Notificações** | **Action Mailer** | Envio de notificações obrigatórias por e-mail (novo ticket, atribuição, atualização). |