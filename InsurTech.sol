pragma solidity >=0.5.0 <0.7.0;


contract Insurance {
    address owner;
    uint public PrecoCarro;
    uint public PrecoCasa;
    uint256 precoBase;
    uint256 precoBaseCasa;
    uint data;
   
    uint [] listaClientes;
    uint [] listaCarrosClientes;
    
    string [] listaPlacaLetra;
    string [] listaPlacaNumero;
    
    struct Cliente {
        address clienteID;
        string Nome;
        uint CPF;
        uint Idade;
        string Profissao;
        uint balance;
        uint quantidadeCasa;
        uint quantidadeCarro;
        uint Dinheiro;
    }
    
    struct Casa {
        address clienteID;
        string Regiao;
        string Tipo;
        uint Valor;
    }
    
    struct Carro {
        address clienteID;
        string Marca;
        uint Ano;
        uint Km;
        uint Valor;
        
        string placa_letra;
        string placa_numero;
    }

    mapping(address => Cliente) dados;
    mapping(address => Casa) casa;
    mapping(address => Carro) carro;

    constructor() public payable{
        owner = msg.sender;
        PrecoCarro = 0;
        PrecoCasa = 0;
        precoBase = 1000;
        precoBaseCasa = 2000;
        
    }

    event TrocoEnviado(address pagador, uint troco);
    
    function cadastroCliente(string memory Nome, uint CPF, uint Idade, string memory Profissao) public payable comCustoMinimo(0){
        
        dados[msg.sender].clienteID = msg.sender;
        dados[msg.sender].Nome = Nome;
        dados[msg.sender].CPF = CPF ;
        dados[msg.sender].Idade = Idade;
        dados[msg.sender].Profissao = Profissao;
        
        listaClientes.push(CPF);
        
        if (msg.value > 0){
            uint troco = msg.value - 0;
            msg.sender.transfer(troco);
            emit TrocoEnviado(msg.sender, troco);
        }
        
        for (uint i=0; i < (listaClientes.length-1);i++){
            require(dados[msg.sender].CPF != listaClientes[i], "CPF já cadastrado.");
            
        }
        
    }
 
    modifier comCustoMinimo(uint min){
        require(msg.value >= min, "Não foi enviado Ether suficiente.");
        _;
    }

    function dadosCliente() public view returns(address, string memory, uint, uint, string memory, uint, uint, uint){
        return (dados[msg.sender].clienteID, dados[msg.sender].Nome, dados[msg.sender].CPF, dados[msg.sender].Idade, dados[msg.sender].Profissao, dados[msg.sender].quantidadeCarro, dados[msg.sender].quantidadeCasa, dados[msg.sender].Dinheiro);
    }
    
    function numeroClientes() public view returns(uint){
        return(listaClientes.length);  
    }
    
    
    
    function deposito(uint valor)public{
        dados[msg.sender].clienteID = msg.sender;
        dados[msg.sender].Dinheiro += valor;
    }
    
    function saque(uint valor)public{
        require(dados[msg.sender].Dinheiro >= valor, "Dinheiro insuficiente");
        dados[msg.sender].clienteID = msg.sender;
        dados[msg.sender].Dinheiro -= valor;
    }



    function cadastroCarro(string memory Marca, uint Ano, uint Km, uint Valor, string memory PL, string memory PN) public{
        carro[msg.sender].clienteID = msg.sender;
        carro[msg.sender].Marca = Marca;
        carro[msg.sender].Ano = Ano ;
        carro[msg.sender].Km = Km;
        carro[msg.sender].Valor = Valor;
        
        carro[msg.sender].placa_letra = PL;
        carro[msg.sender].placa_numero = PN;
        listaPlacaLetra.push(PL);
        listaPlacaNumero.push(PN);
        
        dados[msg.sender].quantidadeCarro += 1;
        
        listaCarrosClientes.push(Valor);
        
        for (uint i=0; i < (listaPlacaLetra.length-1);i++){
             if(keccak256(abi.encodePacked(carro[msg.sender].placa_letra)) == keccak256(abi.encodePacked(listaPlacaLetra[i])) && keccak256(abi.encodePacked(carro[msg.sender].placa_numero)) == keccak256(abi.encodePacked(listaPlacaNumero[i]))){
                require(keccak256(abi.encodePacked(carro[msg.sender].placa_letra)) != keccak256(abi.encodePacked(listaPlacaLetra[i])) && keccak256(abi.encodePacked(carro[msg.sender].placa_numero)) != keccak256(abi.encodePacked(listaPlacaNumero[i])), "Placa já cadastrada.");
              
            }
        }
        
    }
    
    function CalcularSeguroCarro() public returns(uint){
        if (dados[msg.sender].Idade >= 18 && dados[msg.sender].Idade < 28){
            PrecoCarro = PrecoCarro + precoBase + ((precoBase/4)(1-(dados[msg.sender].Idade/100))) + ((precoBase/4)(2020-carro[msg.sender].Ano)) + ((precoBase/40)*(carro[msg.sender].Km/1000));
        }
        else if(dados[msg.sender].Idade >= 28 && dados[msg.sender].Idade < 48){
            PrecoCarro = PrecoCarro + precoBase + ((precoBase/6)(1-(dados[msg.sender].Idade/100))) + ((precoBase/4)(2020-carro[msg.sender].Ano)) + ((precoBase/40)*(carro[msg.sender].Km/1000));
        }
        else if(dados[msg.sender].Idade >= 48 && dados[msg.sender].Idade < 78){
            PrecoCarro = PrecoCarro + precoBase + ((precoBase/8)(1-(dados[msg.sender].Idade/100))) + ((precoBase/4)(2020-carro[msg.sender].Ano)) + ((precoBase/40)*(carro[msg.sender].Km/1000));
        }
        else if(dados[msg.sender].Idade >= 78){
            PrecoCarro = PrecoCarro + precoBase + ((precoBase/10)(1-(dados[msg.sender].Idade/100))) + ((precoBase/4)(2020-carro[msg.sender].Ano)) + ((precoBase/40)*(carro[msg.sender].Km/1000));
        }
        return(PrecoCarro);
    }
    
    function venderCarro(address comprador, uint preco) public{
        require(dados[msg.sender].quantidadeCarro > 0, "Vendedor não possui carro.");
        require(dados[comprador].Dinheiro >= preco, "Comprador não tem dinheiro");
        require(preco <= carro[msg.sender].Valor, "Dinheiro insuficiente");
        dados[comprador].clienteID = comprador;
        dados[comprador].Dinheiro -= preco;
        dados[comprador].quantidadeCarro += 1;
                
        dados[msg.sender].Dinheiro += preco;
        dados[msg.sender].quantidadeCarro -= 1;
    }
    
     function comprarCarro(address vendedor,uint preco) public{
        require(dados[vendedor].quantidadeCarro > 0, "Vendedor não possui carro.");
        require(dados[msg.sender].Dinheiro >= preco, "Comprador não tem dinheiro");
        require(preco >= carro[vendedor].Valor, "Dinheiro insuficiente");
        dados[msg.sender].Dinheiro -= preco;
        dados[msg.sender].quantidadeCarro += 1;
                
        dados[vendedor].clienteID = vendedor;
        dados[vendedor].Dinheiro += preco;
        dados[vendedor].quantidadeCarro -= 1;
    }
    
    
    
    function cadastroCasa(string memory Regiao, string memory Tipo, uint Valor) public{
        casa[msg.sender].clienteID = msg.sender;
        casa[msg.sender].Regiao = Regiao;
        casa[msg.sender].Tipo = Tipo;
        casa[msg.sender].Valor = Valor;
        
        dados[msg.sender].quantidadeCasa += 1;
    
    }
    
    function CalcularSeguroCasa() public returns(uint){
        if (keccak256(abi.encodePacked(casa[msg.sender].Tipo)) == keccak256(abi.encodePacked("casa")) && keccak256(abi.encodePacked(casa[msg.sender].Regiao)) == keccak256(abi.encodePacked("urbana"))){
            PrecoCasa = PrecoCasa + precoBaseCasa + (precoBaseCasa/2) + (precoBaseCasa/4);
        }
        else if (keccak256(abi.encodePacked(casa[msg.sender].Tipo)) == keccak256(abi.encodePacked("casa")) && keccak256(abi.encodePacked(casa[msg.sender].Regiao)) == keccak256(abi.encodePacked("litoral"))){
            PrecoCasa = PrecoCasa + precoBaseCasa + precoBaseCasa + (precoBaseCasa/4);
        }
        else if (keccak256(abi.encodePacked(casa[msg.sender].Tipo)) == keccak256(abi.encodePacked("casa")) && keccak256(abi.encodePacked(casa[msg.sender].Regiao)) == keccak256(abi.encodePacked("rural"))){
            PrecoCasa = PrecoCasa + precoBaseCasa + (precoBaseCasa/4);
        }
        
        if (keccak256(abi.encodePacked(casa[msg.sender].Tipo)) == keccak256(abi.encodePacked("apartamento")) && keccak256(abi.encodePacked(casa[msg.sender].Regiao)) == keccak256(abi.encodePacked("urbana"))){
            PrecoCasa = PrecoCasa + precoBaseCasa + (precoBaseCasa/2);
        }
        else if (keccak256(abi.encodePacked(casa[msg.sender].Tipo)) == keccak256(abi.encodePacked("apartamento")) && keccak256(abi.encodePacked(casa[msg.sender].Regiao)) == keccak256(abi.encodePacked("litoral"))){
            PrecoCasa = PrecoCasa + precoBaseCasa + precoBaseCasa;
        }
        else if (keccak256(abi.encodePacked(casa[msg.sender].Tipo)) == keccak256(abi.encodePacked("apartamento")) && keccak256(abi.encodePacked(casa[msg.sender].Regiao)) == keccak256(abi.encodePacked("rural"))){
            PrecoCasa = PrecoCasa + precoBaseCasa;
        }
        
        return(PrecoCasa);
    }
    
    function venderCasa(address comprador, uint preco) public{
        require(dados[msg.sender].quantidadeCasa > 0, "Vendedor não possui casa.");
        require(dados[comprador].Dinheiro >= preco, "Comprador não tem dinheiro");
        require(preco <= casa[msg.sender].Valor, "Dinheiro insuficiente");
        dados[comprador].clienteID = comprador;
        dados[comprador].Dinheiro -= preco;
        dados[comprador].quantidadeCasa += 1;
                
        dados[msg.sender].Dinheiro += preco;
        dados[msg.sender].quantidadeCasa -= 1;
    }
    
   function comprarCasa(address vendedor,uint preco) public{
        require(dados[vendedor].quantidadeCasa > 0, "Vendedor não possui casa.");
        require(dados[msg.sender].Dinheiro >= preco, "Comprador não tem dinheiro");
        require(preco >= casa[vendedor].Valor, "Dinheiro insuficiente");
        dados[msg.sender].Dinheiro -= preco;
        dados[msg.sender].quantidadeCasa += 1;
                
        dados[vendedor].clienteID = vendedor;
        dados[vendedor].Dinheiro += preco;
        dados[vendedor].quantidadeCasa -= 1;
    }
}
