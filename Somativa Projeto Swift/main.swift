//: Sistema de Notificações com Protocol-Oriented Programming (POP)

import Foundation

enum TipoMensagem {
    case promocao
    case lembrete
    case alerta
}

enum Prioridade {
    case baixa
    case media
    case alta
}

struct Mensagem {
    let tipo: TipoMensagem
    let conteudo: String
    var prioridade: Prioridade = .media
}

protocol Notificavel {
    var mensagem: Mensagem { get set }
    var prioridade: Prioridade { get }
    func enviarNotificacao()
}

extension Notificavel {
    func enviarNotificacao() {
        print("Enviando notificação genérica...")
    }

    var prioridade: Prioridade {
        return .media
    }
}

struct Email: Notificavel {
    var mensagem: Mensagem
    let enderecoEmail: String

    func enviarNotificacao() {
        let urgente = mensagem.prioridade == .alta ? "URGENTE! " : ""
        print("[E-MAIL] \(mensagem.tipo) \(urgente)para \(enderecoEmail): \(mensagem.conteudo)")
    }
}

struct SMS: Notificavel {
    var mensagem: Mensagem
    let numeroTelefone: String

    func enviarNotificacao() {
        print("[SMS] \(mensagem.tipo) para \(numeroTelefone): \(mensagem.conteudo)")
    }
}

struct PushNotification: Notificavel {
    var mensagem: Mensagem
    let tokenDispositivo: String

    func enviarNotificacao() {
        print("[PUSH] \(mensagem.tipo) para dispositivo \(tokenDispositivo): \(mensagem.conteudo)")
    }
}

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
        print("Escolha: ", terminator: "")

        guard let opcao = readLine().flatMap(Int.init) else {
            print("Opção inválida!")
            continue
        }

        switch opcao {
        case 1: criarMensagem(&mensagens)
        case 2: adicionarCanal(&canais, mensagens: mensagens)
        case 3: listarMensagens(mensagens)
        case 4: enviarTodasNotificacoes(canais)
        case 5: filtrarCanais(canais)
        case 6: return
        default: print("Opção inválida!")
        }
    }
}

func criarMensagem(_ mensagens: inout [Mensagem]) {
    print("\n=== NOVA MENSAGEM ===")
    let tipo = selecionarTipoMensagem()
    let prioridade = selecionarPrioridade()

    print("Digite o conteúdo: ", terminator: "")
    guard let conteudo = readLine(), !conteudo.isEmpty else {
        print("Conteúdo inválido!")
        return
    }

    let novaMensagem = Mensagem(
        tipo: tipo,
        conteudo: conteudo,
        prioridade: prioridade
    )

    mensagens.append(novaMensagem)
    print("Mensagem criada com sucesso! (ID: \(mensagens.count-1))")
}

func adicionarCanal(_ canais: inout [Notificavel], mensagens: [Mensagem]) {
    guard !mensagens.isEmpty else {
        print("Crie mensagens primeiro!")
        return
    }

    print("\n=== NOVO CANAL ===")
    listarMensagens(mensagens)
    print("Selecione o ID da mensagem: ", terminator: "")

    guard let idInput = readLine().flatMap(Int.init), mensagens.indices.contains(idInput) else {
        print("ID inválido!")
        return
    }

    let mensagemSelecionada = mensagens[idInput]

    print("""
    \nSelecione o tipo de canal:
    1. Email
    2. SMS
    3. Push Notification
    Opção: 
    """, terminator: "")

    guard let tipoCanal = readLine().flatMap(Int.init) else {
        print("Entrada inválida!")
        return
    }

    switch tipoCanal {
    case 1:
        print("Email: ", terminator: "")
        guard let email = readLine(), !email.isEmpty else {
            print("Email inválido!")
            return
        }
        canais.append(Email(mensagem: mensagemSelecionada, enderecoEmail: email))

    case 2:
        print("Telefone: ", terminator: "")
        guard let telefone = readLine(), !telefone.isEmpty else {
            print("Telefone inválido!")
            return
        }
        canais.append(SMS(mensagem: mensagemSelecionada, numeroTelefone: telefone))

    case 3:
        print("Token: ", terminator: "")
        guard let token = readLine(), !token.isEmpty else {
            print("Token inválido!")
            return
        }
        canais.append(PushNotification(mensagem: mensagemSelecionada, tokenDispositivo: token))

    default:
        print("Tipo inválido!")
    }

    print("Canal adicionado!")
}

func enviarTodasNotificacoes(_ canais: [Notificavel]) {
    print("\n=== INICIANDO ENVIO ===")
    canais.forEach { $0.enviarNotificacao() }
    print("=== \(canais.count) NOTIFICAÇÕES ENVIADAS ===")
}

func filtrarCanais(_ canais: [Notificavel]) {
    print("""
    \nFiltrar por:
    1. Email
    2. SMS
    3. Push Notification
    Opção: 
    """, terminator: "")

    guard let tipo = readLine().flatMap(Int.init) else {
        print("Entrada inválida!")
        return
    }

    switch tipo {
    case 1:
        let filtrados = canais.compactMap { $0 as? Email }
        print("\n=== \(filtrados.count) EMAILS ===")
        filtrados.forEach { $0.enviarNotificacao() }

    case 2:
        let filtrados = canais.compactMap { $0 as? SMS }
        print("\n=== \(filtrados.count) SMS ===")
        filtrados.forEach { $0.enviarNotificacao() }

    case 3:
        let filtrados = canais.compactMap { $0 as? PushNotification }
        print("\n=== \(filtrados.count) PUSHES ===")
        filtrados.forEach { $0.enviarNotificacao() }

    default:
        print("Tipo inválido!")
    }
}

func selecionarTipoMensagem() -> TipoMensagem {
    print("""
    Selecione o tipo:
    1. Promoção
    2. Lembrete
    3. Alerta
    Opção: 
    """, terminator: "")

    guard let input = readLine().flatMap(Int.init), (1...3).contains(input) else {
        print("Usando padrão: Promoção")
        return .promocao
    }

    switch input {
    case 1: return .promocao
    case 2: return .lembrete
    case 3: return .alerta
    default: return .promocao
    }
}

func selecionarPrioridade() -> Prioridade {
    print("""
    Selecione a prioridade:
    1. Baixa
    2. Média
    3. Alta
    Opção: 
    """, terminator: "")

    guard let input = readLine().flatMap(Int.init), (1...3).contains(input) else {
        print("Usando padrão: Média")
        return .media
    }

    switch input {
    case 1: return .baixa
    case 2: return .media
    case 3: return .alta
    default: return .media
    }
}

func listarMensagens(_ mensagens: [Mensagem]) {
    print("\n=== MENSAGENS SALVAS ===")
    for (index, msg) in mensagens.enumerated() {
        print("""
        [ID \(index)] \(msg.tipo) (\(msg.prioridade))
        Conteúdo: \(msg.conteudo)
        """)
    }
}

main()