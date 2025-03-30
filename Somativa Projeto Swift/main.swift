// Sistema de Gerenciamento de Notificações, simplificada para envio de mensagens por múltiplos canais

// Tipos de mensagens suportados pelo sistema
enum TipoMensagem: Int {
    case promocao   
    case lembrete   
    case alerta    
}

// Níveis de prioridade para organização das mensagens
enum Prioridade: Int {
    case baixa    
    case media       
    case alta       
}

// Estrutura principal de uma mensagem
struct Mensagem {
    let tipo: TipoMensagem 
    let conteudo: String     
    var prioridade: Prioridade = .media
}

// Protocolo base para todos os tipos de notificação
protocol Notificavel {
    var mensagem: Mensagem { get set }  
    var prioridade: Prioridade { get }  
    func enviarNotificacao()            
}

// Implementação padrão para métodos comuns
extension Notificavel {
    func enviarNotificacao() {
        print("Enviando notificação genérica...")
    }
    
    var prioridade: Prioridade {
        return .media  
    }
}

// envio por e-mail
struct Email: Notificavel {
    var mensagem: Mensagem
    let enderecoEmail: String  

    func enviarNotificacao() {
        let urgente = mensagem.prioridade == .alta ? "[URGENTE] " : ""
        print("[E-MAIL] \(mensagem.tipo) \(urgente)para \(enderecoEmail): \(mensagem.conteudo)")
    }
}

// envio por SMS
struct SMS: Notificavel {
    var mensagem: Mensagem
    let numeroTelefone: String  

    func enviarNotificacao() {
        print("[SMS] \(mensagem.tipo) para \(numeroTelefone): \(mensagem.conteudo)")
    }
}

// notificação push
struct PushNotification: Notificavel {
    var mensagem: Mensagem
    let tokenDispositivo: String  // Identificador

    func enviarNotificacao() {
        print("[PUSH] \(mensagem.tipo) para dispositivo \(tokenDispositivo): \(mensagem.conteudo)")
    }
}

// Função que gerencia o fluxo do programa
func main() {
    var canais: [Notificavel] = []  
    var mensagens: [Mensagem] = []   

    while true {
        print("\n=== MENU PRINCIPAL ===")
        print("1. Criar nova mensagem")
        print("2. Adicionar canal de notificação")
        print("3. Listar mensagens salvas")
        print("4. Enviar todas as notificações")
        print("5. Filtrar canais por tipo")
        print("6. Sair")
        
        var opcao = 0
        repeat {
            print("Escolha: ", terminator: "")
            if let input = readLine(), let numero = Int(input), (1...6).contains(numero) {
                opcao = numero
            } else {
                print("!Opcao invalida! Digite um numero entre 1 e 6")
            }
        } while opcao == 0

        switch opcao {
        case 1: criarMensagem(&mensagens)
        case 2: adicionarCanal(&canais, mensagens: mensagens)
        case 3: listarMensagens(mensagens)
        case 4: enviarTodasNotificacoes(canais)
        case 5: filtrarCanais(canais)
        case 6: 
            print("\nOperacao finalizada. Ate logo!")
            return
        default: break
        }
    }
}

// Cria uma nova mensagem e armazena em lista
func criarMensagem(_ mensagens: inout [Mensagem]) {
    print("\n=== NOVA MENSAGEM ===")
    let tipo = selecionarTipoMensagem()
    let prioridade = selecionarPrioridade()

    print("Digite o conteudo: ", terminator: "")
    guard let conteudo = readLine(), !conteudo.isEmpty else {
        print("!Conteudo invalido!")
        return
    }

    let novaMensagem = Mensagem(
        tipo: tipo,
        conteudo: conteudo,
        prioridade: prioridade
    )

    mensagens.append(novaMensagem)
    print("!Mensagem criada com sucesso! ID: \(mensagens.count-1)")
}

// Adiciona novo canal de notificação
func adicionarCanal(_ canais: inout [Notificavel], mensagens: [Mensagem]) {
    guard !mensagens.isEmpty else {
        print("!Crie mensagens primeiro!")
        return
    }

    print("\n=== NOVO CANAL ===")
    listarMensagens(mensagens)
    guard let mensagemSelecionada = selecionarMensagem(mensagens) else {
        print("!Selecao de mensagem invalida!")
        return
    }

    guard let canal = criarCanal(mensagemSelecionada) else {
        print("Falha ao criar o canal")
        return
    }

    canais.append(canal)
    print("!Canal adicionado com sucesso!")
}

// menu de seleção de tipos de canais
func criarCanal(_ mensagem: Mensagem) -> Notificavel? {
    var tipoCanal = 0
    repeat {
        print("""
        Selecione o tipo de canal:
        1. Email
        2. SMS
        3. Push Notification
        Opcao: 
        """, terminator: "")
        
        if let input = readLine(), let numero = Int(input), (1...3).contains(numero) {
            tipoCanal = numero
        } else {
            print("!Tipo invalido! Digite de 1 a 3")
        }
    } while tipoCanal == 0

    switch tipoCanal {
    case 1: return criarCanalEmail(mensagem)
    case 2: return criarCanalSMS(mensagem)
    case 3: return criarCanalPush(mensagem)
    default: return nil
    }
}

// Cria canal e-mail
func criarCanalEmail(_ mensagem: Mensagem) -> Notificavel? {
    print("Email: ", terminator: "")
    guard let email = readLine(), !email.isEmpty else {
        print("Endereco de email invalido")
        return nil
    }
    return Email(mensagem: mensagem, enderecoEmail: email)
}

// Cria canal SMS
func criarCanalSMS(_ mensagem: Mensagem) -> Notificavel? {
    print("Telefone: ", terminator: "")
    guard let telefone = readLine(), !telefone.isEmpty else {
        print("Numero de telefone invalido")
        return nil
    }
    return SMS(mensagem: mensagem, numeroTelefone: telefone)
}

// Cria canal Push
func criarCanalPush(_ mensagem: Mensagem) -> Notificavel? {
    print("Token: ", terminator: "")
    guard let token = readLine(), !token.isEmpty else {
        print("Token invalido")
        return nil
    }
    return PushNotification(mensagem: mensagem, tokenDispositivo: token)
}

// Seleciona uma mensagem pelo ID
func selecionarMensagem(_ mensagens: [Mensagem]) -> Mensagem? {
    var id = -1
    repeat {
        print("Selecione o ID da mensagem: ", terminator: "")
        if let input = readLine(), let numero = Int(input), mensagens.indices.contains(numero) {
            id = numero
        } else {
            print("!ID invalido! Digite um numero entre 0 e \(mensagens.count-1)")
        }
    } while id == -1
    return mensagens[id]
}

// Envia todas as notificações cadastradas
func enviarTodasNotificacoes(_ canais: [Notificavel]) {
    print("\n=== INICIANDO ENVIO ===")
    canais.forEach { $0.enviarNotificacao() }
    print("Total enviado: \(canais.count) notificacoes")
}

// Filtra canais por tipo
func filtrarCanais(_ canais: [Notificavel]) {
    var tipo = 0
    repeat {
        print("""
        Filtrar por:
        1. Email
        2. SMS
        3. Push Notification
        Opcao: 
        """, terminator: "")
        
        if let input = readLine(), let numero = Int(input), (1...3).contains(numero) {
            tipo = numero
        } else {
            print("!Tipo invalido! Digite de 1 a 3")
        }
    } while tipo == 0

    switch tipo {
    case 1:
        let filtrados = canais.compactMap { $0 as? Email }
        print("\nCanais de Email (\(filtrados.count)):")
        filtrados.forEach { $0.enviarNotificacao() }
    case 2:
        let filtrados = canais.compactMap { $0 as? SMS }
        print("\nCanais de SMS (\(filtrados.count)):")
        filtrados.forEach { $0.enviarNotificacao() }
    case 3:
        let filtrados = canais.compactMap { $0 as? PushNotification }
        print("\nCanais de Push (\(filtrados.count)):")
        filtrados.forEach { $0.enviarNotificacao() }
    default: break
    }
}

// menu de seleção de tipo de menssagem
func selecionarTipoMensagem() -> TipoMensagem {
    var choice = 0
    repeat {
        print("""
        Selecione o tipo:
        1. Promocao
        2. Lembrete
        3. Alerta
        Opcao: 
        """, terminator: "")
        
        if let input = readLine(), let numero = Int(input), (1...3).contains(numero) {
            choice = numero
        } else {
            print("!Tipo invalido! Digite de 1 a 3")
        }
    } while choice == 0
    
    switch choice {
    case 1: return .promocao
    case 2: return .lembrete
    case 3: return .alerta
    default: return .promocao
    }
}

// Seleção de prioridades
func selecionarPrioridade() -> Prioridade {
    var choice = 0
    repeat {
        print("""
        Selecione a prioridade:
        1. Baixa
        2. Media
        3. Alta
        Opcao: 
        """, terminator: "")
        
        if let input = readLine(), let numero = Int(input), (1...3).contains(numero) {
            choice = numero
        } else {
            print("!Prioridade invalida! Digite de 1 a 3")
        }
    } while choice == 0
    
    switch choice {
    case 1: return .baixa
    case 2: return .media
    case 3: return .alta
    default: return .media
    }
}

// Lista as mensagens armazenadas
func listarMensagens(_ mensagens: [Mensagem]) {
    print("\n=== MENSAGENS SALVAS ===")
    for (index, msg) in mensagens.enumerated() {
        print("""
        [ID \(index)] \(msg.tipo) (\(msg.prioridade))
        Conteudo: \(msg.conteudo)
        """)
    }
}

// execução do programa
main()