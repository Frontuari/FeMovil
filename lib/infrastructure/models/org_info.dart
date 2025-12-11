class OrgInfo {

    dynamic adORGID;
   dynamic name;
   dynamic orgAddress;
   dynamic taxID;
    dynamic suggestedQty;



  OrgInfo({
    this.adORGID,
    this.name,
    this.taxID , 
    this.orgAddress
  
  });

  

  // Método para convertir a un mapa (para base de datos)
  Map<String, dynamic> toMap() {
    return {
      'ad_org_id': adORGID,
      'name': name,
      'ruc': taxID,
      'address':orgAddress
    
    };
  }

  // Método para crear un objeto desde un mapa (cuando lees de la BD)
  factory OrgInfo.fromMap(Map<String, dynamic> map) {
    return OrgInfo(
      adORGID: map['ad_org_id'],
      name: map['name'],  
      taxID: map['ruc'],
      orgAddress: map['address']   
    );
  }
}