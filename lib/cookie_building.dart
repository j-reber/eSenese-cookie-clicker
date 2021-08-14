class CookieBuilding{
  String name;
  int cost;
  int cps;
  final double priceIncrement = 1.15;

  CookieBuilding(this.name, this.cost, this.cps);


  void buildingBought(){
    cost = (priceIncrement * cost).round();
  }


}
