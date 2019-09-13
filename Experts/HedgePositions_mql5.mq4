//+------------------------------------------------------------------+
//|                                               HedgePositions.mq4 |
//|                                           Copyright 2019, Pablo. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Pablo."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//Variables
int magic = 17;
int magicHedge = 18;
input double lots = 0.01;
input double TP = 1.17;
input double startPrice = 1.155;
double firstEntryPrice;
bool UpDown;

bool oportunity = true;
int slippage = 10;

//state = Hedge
input double hedgeDistance = 400; //distance in points (not pips) from the low to SL - Entry point for hedge
input double reOpenDistance = 500;
double reOpenPrice = 0; //Price at which we will re-enter the market
double hedgePrice = 0; //Price at which we open our hedge to cover from losses

input int buyDays = 30;
input int sellDays = 30;

enum States
{
   Wait, //Wait for a better price before entering the market
   First_Entry, //Make the first trade and start operating
   Open_Hedge, //Hedge the position if it goes agains us
   Close_Hedge, //Closes the hedge to enter the market again
   Finish //Send an email to me to turn off the EA in that specific pair and find a new pair
};

States state;

int OnInit()
  {
   state = Wait;
   UpDown = UpDown(startPrice, TP);
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
  }
void OnTick()
  {
   if(iHigh(NULL,PERIOD_W1,0) >= TP || iHigh(NULL,PERIOD_D1,1) >= TP)
   {
      //Price touched TP, so we stop operating that pair
      state = Finish;      
   }
   if(UpDown == 1) //Long position
   {
      switch(state)
      {
      case Wait:
      //If price touches our start price, we start looking for an entry oportunity
         if(iLow(NULL,PERIOD_D1,0) <= startPrice)
         {
            reOpenPrice = trailingPrice("down",0,reOpenDistance);
            state = First_Entry;            
         }
      break;
      case First_Entry:
         reOpenPrice = trailingPrice("down",reOpenPrice,reOpenDistance);
         if(buyOportunity(buyInterest()) == true || Ask >= reOpenPrice)
         {            
            MarketOrderSend(Symbol(),OP_BUY,lots,Ask,10,NULL,NULL,NULL,magic,0,clrGreen);
            reOpenPrice = trailingPrice("down",0,reOpenDistance);
            state=Open_Hedge;
         }   
      break;
      case Open_Hedge:
         //We constantly check our re-entry pices
         reOpenPrice = trailingPrice("down",reOpenPrice,reOpenDistance);
         hedgePrice = trailingPrice("up",hedgePrice,hedgeDistance); 
         
         if(checkTakeProfit(TP,"buy")==true)
            state = Finish;   
            
         for(int i = OrdersTotal()-1;i>=0;i--)
         {
            OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            if(OrderMagicNumber() == magic)
            {
               firstEntryPrice = OrderOpenPrice();
            }
         }  
         if(Bid > firstEntryPrice + 500*_Point)
         {
            if(sellOportunity(sellInterest()) == true || Bid <= hedgePrice)
            {
               CloseOrders(magic);
               hedgePrice = trailingPrice("up",0,hedgeDistance);
               state = Close_Hedge;
            } 
         }
         if(Bid <= firstEntryPrice + 500*_Point)
         {
            if(sellOportunity(sellInterest()) == true || Bid <= hedgePrice)
            {
               CloseOrders(magic);
               hedgePrice = trailingPrice("up",0,hedgeDistance);
               state = Close_Hedge;
            } 
         }
          
      break;
      case Close_Hedge:
         if(checkTakeProfit(TP,"buy")==true)
            state = Finish;   
            
         //We constantly check our re-entry pices
         reOpenPrice = trailingPrice("down",reOpenPrice,reOpenDistance);
         hedgePrice = trailingPrice("up",hedgePrice,hedgeDistance); 
         if(buyOportunity(buyInterest()) == true || Ask >= reOpenPrice)
         {
            MarketOrderSend(Symbol(),OP_BUY,lots,Ask,10,NULL,NULL,NULL,magic,0,clrGreen);
            reOpenPrice = trailingPrice("down",0,reOpenDistance);
            state=Open_Hedge;
         }
         
      break;
      case Finish:
         CloseOrders(magic);         
         CloseOrders(magicHedge);
         oportunity = false;
         SendMail("Finish","Your pair has touched take profit");
      break;
      default:
         SendMail("Error","Switch state got to default, but that should never happen");
         break;
   } //end of switch
   
   
   }else if(UpDown == 0) //Short position
   {
      switch(state)
      {
      case Wait:
      //If price touches our start price, we start looking for an entry oportunity
         if(iHigh(NULL,PERIOD_D1,0) >= startPrice)
         {
            reOpenPrice = trailingPrice("up",0,reOpenDistance);
            state = First_Entry;            
         }
      break;
      case First_Entry:
         reOpenPrice = trailingPrice("up",reOpenPrice,reOpenDistance);
         if(sellOportunity(sellInterest()) == true || Bid >= reOpenPrice)
         {            
            MarketOrderSend(Symbol(),OP_SELL,lots,Bid,10,NULL,NULL,NULL,magic,0,clrGreen);
            reOpenPrice = trailingPrice("up",0,reOpenDistance);
            state=Open_Hedge;
         }   
      break;
      case Open_Hedge:
         //We constantly check our re-entry pices
         reOpenPrice = trailingPrice("up",reOpenPrice,reOpenDistance);
         hedgePrice = trailingPrice("down",hedgePrice,hedgeDistance); 
         
         if(checkTakeProfit(TP,"sell")==true)
            state = Finish;   
            
         for(int i = OrdersTotal()-1;i>=0;i--)
         {
            OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            if(OrderMagicNumber() == magic)
            {
               firstEntryPrice = OrderOpenPrice();
            }
         }  
         if(Ask < firstEntryPrice + 500*_Point)
         {
            if(buyOportunity(buyInterest()) == true || Ask >= hedgePrice)
            {
               CloseOrders(magic);
               hedgePrice = trailingPrice("down",0,hedgeDistance);
               state = Close_Hedge;
            } 
         }
         if(Ask >= firstEntryPrice + 500*_Point)
         {
            if(buyOportunity(buyInterest()) == true || Ask >= hedgePrice)
            {
               CloseOrders(magic);
               hedgePrice = trailingPrice("down",0,hedgeDistance);
               state = Close_Hedge;
            } 
         }
          
      break;
      case Close_Hedge:
         if(checkTakeProfit(TP,"sell") == true)
            state = Finish;   
            
         //We constantly check our re-entry pices
         reOpenPrice = trailingPrice("up",reOpenPrice,reOpenDistance);
         hedgePrice = trailingPrice("down",hedgePrice,hedgeDistance); 
         if(sellOportunity(sellInterest()) == true || Bid <= reOpenPrice)
         {
            MarketOrderSend(Symbol(),OP_SELL,lots,Bid,10,NULL,NULL,NULL,magic,0,clrGreen);
            reOpenPrice = trailingPrice("up",0,reOpenDistance);
            state=Open_Hedge;
         }
         
      break;
      case Finish:
         CloseOrders(magic);         
         CloseOrders(magicHedge);
         oportunity = false;
         SendMail("Finish","Your pair has touched take profit");
      break;
      default:
         SendMail("Error","Switch state got to default, but that should never happen");
         break;
   } //end of switch
   }
  } //end of OnTick()


int MarketOrderSend(string symbol, int cmd, double volume, double price, int slipagge, double stoploss, double takeprofit, string comment, int magicN, datetime date, color colour)
{
   int newOrder;
   
   newOrder = OrderSend(symbol, cmd, volume, price, slippage, stoploss, takeprofit, NULL, magicN, date, colour);
   if(newOrder <= 0)Alert("OrderSend Error: ", GetLastError());
   
   return(newOrder);
}

void CloseOrders(int magicN)
{
   for(int i = OrdersTotal()-1;i>=0;i--)
   {
      
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      Print("Magic: " , OrderMagicNumber());
      if(OrderMagicNumber() == magicN)
      {
         if(OrderType() == OP_BUY)
         {
            OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),slippage);
         }
         if(OrderType() == OP_SELL)
         {
            OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),slippage);
         }         
      }else{
         Print("OrderMagicNumber Error: " , GetLastError());
      }
   }
}

//INCLUDES

bool checkTakeProfit(double TP, string type)
{  
   //returns true if price has touched take profit. False if not
   if(type == "buy")
   {
      if(Bid >= TP)
         return true;
      else
         return false;   
   }
   if(type == "sell")
   {
      if(Ask <= TP)
         return true;
      else
         return false;         
   }
   //IF there is an error, return false
   return false;
}

bool buyInterest()
{   
   double mechaSize;
   double mechaD1MinPips = 400*_Point;
   double envolventeMinPips = 300*_Point;
   double envolventeSize;
 
   //Hammer with open >= close //Martillo
   if(iOpen(NULL,PERIOD_D1,1) >= iClose(NULL,PERIOD_D1,1))
   {
      if((iClose(NULL,PERIOD_D1,1)-iLow(NULL,PERIOD_D1,1)) >= mechaD1MinPips)
      {
         //Candle's body must be at least half of the mecha
         if((iOpen(NULL,PERIOD_D1,1)-iClose(NULL,PERIOD_D1,1))
         < 2*(iClose(NULL,PERIOD_D1,1)-iLow(NULL,PERIOD_D1,1)))
         {
            mechaSize = iClose(NULL,PERIOD_D1,1) - iLow(NULL,PERIOD_D1,1);
            //Upper mecha must be 1/3 or less of the size
            if(iOpen(NULL,PERIOD_D1,1)+(mechaSize/3) > iHigh(NULL,PERIOD_D1,1)){
               return true;
            }
         }         
      }
   //Hammer with close > Open //Martillo
   }
   if(iOpen(NULL,PERIOD_D1,1) < iClose(NULL,PERIOD_D1,1))
   {
      if((iOpen(NULL,PERIOD_D1,1)-iLow(NULL,PERIOD_D1,1)) >= mechaD1MinPips)
      {
         if((iClose(NULL,PERIOD_D1,1)-iOpen(NULL,PERIOD_D1,1))
         < 2*(iOpen(NULL,PERIOD_D1,1)-iLow(NULL,PERIOD_D1,1)))
         {
            mechaSize = iOpen(NULL,PERIOD_D1,1) - iLow(NULL,PERIOD_D1,1);
            //Upper mecha must be 1/3 or less of the size
            if(iClose(NULL,PERIOD_D1,1)+(mechaSize/3) > iHigh(NULL,PERIOD_D1,1)){
               return true;
            }
         } 
      }
   }
   //Envolvente Alcista
   if(iOpen(NULL,PERIOD_D1,2) > (iClose(NULL,PERIOD_D1,2) + envolventeMinPips))
   {
      if(iClose(NULL,PERIOD_D1,1) > iClose(NULL,PERIOD_D1,2))
      {
         envolventeSize = iOpen(NULL,PERIOD_D1,2) - iClose(NULL,PERIOD_D1,2);
         if((iClose(NULL,PERIOD_D1,1) - iOpen(NULL,PERIOD_D1,1)) > 0.6*(envolventeSize))
         {
            if((iClose(NULL,PERIOD_D1,1) - iOpen(NULL,PERIOD_D1,1)) < 1.3 *(envolventeSize))
            {
               return true;
            }
         }
      }
   }
   return false;
}

bool sellInterest()
{
   double mechaSize;
   double mechaD1MinPips = 400*_Point;
   double envolventeMinPips = 300*_Point;
   double envolventeSize;
 
   //Inverted Hammer with open >= close //Martillo invertido
   if(iOpen(NULL,PERIOD_D1,1) >= iClose(NULL,PERIOD_D1,1))
   {
      mechaSize = iHigh(NULL,PERIOD_D1,1) - iOpen(NULL,PERIOD_D1,1);
      if(mechaSize >= mechaD1MinPips)
      {
         //Candle's body must be at least half of the mecha
         if((iOpen(NULL,PERIOD_D1,1)-iClose(NULL,PERIOD_D1,1)) < 2*mechaSize)
         {           
            //Upper mecha must be 1/3 or less of the size
            if(iClose(NULL,PERIOD_D1,1)+(mechaSize/3) < iLow(NULL,PERIOD_D1,1)){
               return true;
            }
         }         
      }
   //Inverted Hammer with close > Open //Martillo invertido
   }
   if(iOpen(NULL,PERIOD_D1,1) < iClose(NULL,PERIOD_D1,1))
   {
      mechaSize = iHigh(NULL,PERIOD_D1,1) - iClose(NULL,PERIOD_D1,1);
      if(mechaSize >= mechaD1MinPips)
      {
         if((iClose(NULL,PERIOD_D1,1)-iOpen(NULL,PERIOD_D1,1)) < 2*mechaSize)
         {            
            //Upper mecha must be 1/3 or less of the size
            if(iOpen(NULL,PERIOD_D1,1)+(mechaSize/3) < iLow(NULL,PERIOD_D1,1)){
               return true;
            }
         } 
      }
   }
   //Envolvente bajista
   if(iOpen(NULL,PERIOD_D1,2) < (iClose(NULL,PERIOD_D1,2) - envolventeMinPips))
   {
      if(iClose(NULL,PERIOD_D1,1) < iClose(NULL,PERIOD_D1,2))
      {
         envolventeSize = iClose(NULL,PERIOD_D1,2) - iOpen(NULL,PERIOD_D1,2);
         if((iOpen(NULL,PERIOD_D1,1) - iClose(NULL,PERIOD_D1,1)) > 0.6*(envolventeSize))
         {
            if(iOpen(NULL,PERIOD_D1,1) - (iClose(NULL,PERIOD_D1,1)) < 1.3 *(envolventeSize))
            {
               return true;
            }
         }
      }
   }
   return false;
}


bool buyOportunity(bool buyInterest)
{
   bool priceAtMin = false;

   //We check that our buyInterest is at a 7-day low or 20pips higher    
   if(getLow("D1",buyDays) + 200*_Point >= iClose(NULL,PERIOD_D1,1) )
      priceAtMin = true;
   
   //We only buy if we have buyInterest and price is at a relative low
   if(buyInterest==true && priceAtMin == true)
      return true;
      
   else if(buyInterest==false && priceAtMin == true)
      return false;   
      
   else if(buyInterest==true && priceAtMin == false)
      return false;
      
   else if(buyInterest==false && priceAtMin == false)
      return false;
        
   else
      return false;       
}

bool sellOportunity(bool sellInterest)
{
   bool priceAtMax = false;

   //We check that our sellInterest is at a 30-day high or 20pips lower    
   if(getHigh("D1",sellDays) - 200*_Point <= iHigh(NULL,PERIOD_D1,1) )
      priceAtMax = true;
      
   if(sellInterest==true && priceAtMax == true)
      return true;
      
   else if(sellInterest==false && priceAtMax == true)
      return false;   
      
   else if(sellInterest==true && priceAtMax == false)
      return false;
      
   else if(sellInterest==false && priceAtMax == false)
      return false;
        
   else
      return false;       
}


double getLow(string timeframe, int nCandles)
{
   double low = 999999;
   
   for(int i=0;i<nCandles;i++)
   {
      if(timeframe == "M30")
      {
         if(iLow(NULL,PERIOD_M30,i) < low)
            low = iLow(NULL,PERIOD_M30,i);
                  
      }else if(timeframe == "H1")
      {
         if(iLow(NULL,PERIOD_H1,i) < low)     
            low = iLow(NULL,PERIOD_H1,i);
          
      }else if(timeframe == "H4")
      {
         if(iLow(NULL,PERIOD_H4,i) < low)     
            low = iLow(NULL,PERIOD_H4,i);
      }else if(timeframe == "D1")
      {
         if(iLow(NULL,PERIOD_D1,i) < low)     
            low = iLow(NULL,PERIOD_D1,i);
      }else if(timeframe == "W1")
      {
         if(iLow(NULL,PERIOD_W1,i) < low)     
            low = iLow(NULL,PERIOD_W1,i);
      }
   }
   if(low == 999999)
      Alert("Error in <getLowMax.mqh>. We return value of: ", low);
    
   return low;   
}

double getHigh(string timeframe, int nCandles)
{
   double high = 0;
   
   for(int i=0;i<nCandles;i++)
   {
      if(timeframe == "M30")
      {
         if(iHigh(NULL,PERIOD_M30,i) > high)
            high = iHigh(NULL,PERIOD_M30,i);
                  
      }else if(timeframe == "H1")
      {
         if(iHigh(NULL,PERIOD_H1,i) > high)     
            high = iHigh(NULL,PERIOD_H1,i);
          
      }else if(timeframe == "H4")
      {
         if(iHigh(NULL,PERIOD_H4,i) > high)     
            high = iHigh(NULL,PERIOD_H4,i);
      }else if(timeframe == "D1")
      {
         if(iHigh(NULL,PERIOD_D1,i) > high)     
            high = iHigh(NULL,PERIOD_D1,i);
      }else if(timeframe == "W1")
      {
         if(iHigh(NULL,PERIOD_W1,i) > high)     
            high = iHigh(NULL,PERIOD_W1,i);
      }
   }
   if(high == 0)
      Alert("Error in <getLowMax.mqh>. We return value of: ", high);
    
   return high;   
}


double trailingPrice(string type, double trailingPrice, double distance)
{  
   distance = distance * _Point;
   if(type == "up")
   {
      if(trailingPrice == 0)
         return Bid - distance; //If trailingPrice is not set
      else if(Bid - distance > trailingPrice)
         return Bid - distance; //Price has increased, so we increase our trailing price
      else if(Bid - distance <= trailingPrice)
         return trailingPrice; //Price has decreased, so we return the same value   
      
      
   }
   else if(type == "down")
   {
      if(trailingPrice == 0)
         return Ask+distance; //If trailingPrice is not set    
      else if(Ask + distance > trailingPrice)
         return trailingPrice; //Price has increased, so we return the same value
      else if(Ask + distance <= trailingPrice)
         return Ask + distance; //Price has decreased, so we lower our trailing price
      
   }else
   {
      return 0; //Error. This should never happen
   }
   return 0; //Error. This should never happen
}


bool UpDown(double startPrice, double TP)
{
   if(startPrice < TP)
      return 1; //Up. Our position is long/buy
   else if(startPrice > TP)
      return 0; //Down. Our position is short/sell
   else
      return 0;   
}