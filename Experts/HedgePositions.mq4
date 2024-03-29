//+------------------------------------------------------------------+
//|                                               HedgePositions.mq4 |
//|                                           Copyright 2019, Pablo. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Pablo."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//Includes
#include <states.mqh>
#include <entryInterest.mqh>
#include <trailingPrice.mqh>
#include <getLowMax.mqh>
#include <entryOportunity.mqh>
#include <checkTakeProfit.mqh>
#include <UpDown.mqh>

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
   if(UpDown == 1) //Long position
   {
      if(checkTakeProfit(TP,"buy")==true)
            state = Finish; 
            
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
             
         //We select the price at which we opened last position   
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
         else if(Bid <= firstEntryPrice + 500*_Point)
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
      if(checkTakeProfit(TP,"sell")==true)
            state = Finish;   
            
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
         if(sellOportunity(sellInterest()) == true || Bid <= reOpenPrice)
         {            
            MarketOrderSend(Symbol(),OP_SELL,lots,Ask,10,NULL,NULL,NULL,magic,0,clrGreen);
            reOpenPrice = trailingPrice("up",0,reOpenDistance);
            state=Open_Hedge;
         }   
      break;
      case Open_Hedge:
         //We constantly check our re-entry pices
         reOpenPrice = trailingPrice("up",reOpenPrice,reOpenDistance);
         hedgePrice = trailingPrice("down",hedgePrice,hedgeDistance); 
                    
         //We select the price at which we opened last position           
         for(int i = OrdersTotal()-1;i>=0;i--)
         {
            OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            if(OrderMagicNumber() == magic)
            {
               firstEntryPrice = OrderOpenPrice();
            }
         }  
         if(Ask < firstEntryPrice - 500*_Point)
         {
            if(buyOportunity(buyInterest()) == true || Ask >= hedgePrice)
            {
               CloseOrders(magic);
               hedgePrice = trailingPrice("down",0,hedgeDistance);
               state = Close_Hedge;
            } 
         }
         else if(Ask >= firstEntryPrice - 500*_Point)
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
            
         //We constantly check our re-entry pices
         reOpenPrice = trailingPrice("up",reOpenPrice,reOpenDistance);
         hedgePrice = trailingPrice("down",hedgePrice,hedgeDistance); 
         
         if(sellOportunity(sellInterest()) == true || Bid <= reOpenPrice)
         {
            MarketOrderSend(Symbol(),OP_SELL,lots,Bid,10,NULL,NULL,NULL,magic,0,clrRed);
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