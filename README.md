# OlhoDigital

OlhoDigital é um aplicativo Flutter desenvolvido para oferecer assistência a pessoas com deficiência visual. Ele captura imagens do ambiente, processa automaticamente as informações e descreve a cena de maneira acessível através de texto e leitura por voz.

## Funcionalidades
 
 - Captura de Imagem: Capture rapidamente uma foto do ambiente.
 - Processamento Inteligente: As imagens são enviadas para o servidor, onde objetos são detectados e suas distâncias em relação ao usuário são calculadas.
 - Descrição de Cena: Receba uma descrição textual do ambiente.
 - Configurações de Acessibilidade: Permite ativar ou desativar a leitura por voz conforme a preferência do usuário.

## Tecnologias Utilizadas

 - Flutter para o desenvolvimento do aplicativo.
 - Camera Plugin para captura de imagens.
 - HTTP Client para comunicação com o servidor.
 - TTS (Text-to-Speech) para leitura de texto em voz alta.
 - [API de Detecção de Objetos](https://github.com/amandazeved/api-flask-yolo) no backend para reconhecimento e cálculo de distâncias. 

## Como executar projeto

1. Clone o repositório:
```bash
git clone https://github.com/amandazeved/application-OlhoDigital.git
cd application-OlhoDigital
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute o aplicativo:
```bash
flutter run
```

