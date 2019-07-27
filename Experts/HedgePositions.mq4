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

//Variables
input int magic = 17;
input int magicHedge = 18;
input double lots = 0.01;
input double SL = 20;
input double TP = 1.2;
input double startPrice = 1.14;

bool oportunity = true;
int slippage = 10;

//state = Hedge
input double hedgeDistance = 800; //distance in points (not pips) from the low to SL - Entry point for hedge
input double reOpenDistance = 800;
double reOpenPrice = 0; //Price at which we will re-enter the market
double hedgePrice = 0; //Price at which we open our hedge to cover from losses


int OnInit()
  {
   state = Wait;
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
  }
void OnTick()
  {
   if(iHigh(NULL,PERIOD_W1,0) >= TP)
   {
      //Price touched TP, so we stop operating that pair
      oportunity = false;
   }
   
   switch(state)
   {
      case Wait:
      //If price touches our start price, we start looking for an entry oportunity
         if(iLow(NULL,PERIOD_H1,0) <= startPrice)
         {
            state = First_Entry;
            reOpenPrice = trailingPrice("down",reOpenPrice,reOpenDistance);
            hedgePrice = trailingPrice("up",hedgePrice,hedgeDistance);   
         }
      break;
      case First_Entry:
         if(buyOportunity(buyInterest()) == true || Ask >= reOpenPrice)
         {
            int buy = OrderSend(Symbol(),OP_BUY,0.01,Ask,10,NULL,NULL,NULL,magic,0,clrGreen);
            reOpenPrice = trailingPrice("down",0,reOpenDistance);
            state=Open_Hedge;
         }   
      break;
      case Open_Hedge:
         //We constantly check our re-entry pices
         reOpenPrice = trailingPrice("down",reOpenPrice,reOpenDistance);
         hedgePrice = trailingPrice("up",hedgePrice,hedgeDistance); 
         if(sellOportunity(sellInterest()) == true || Bid <= hedgePrice)
         {
            int sell = OrderSend(Symbol(),OP_SELL,0.01,Bid,10,NULL,NULL,NULL,magicHedge,0,clrRed);
            hedgePrice = trailingPrice("up",0,hedgeDistance);
            state = Close_Hedge;
         }    
      break;
      case Close_Hedge:
         //We constantly check our re-entry pices
         reOpenPrice = trailingPrice("down",reOpenPrice,reOpenDistance);
         hedgePrice = trailingPrice("up",hedgePrice,hedgeDistance); 
         if(buyOportunity(buyInterest()) == true || Ask >= reOpenPrice)
         {
            CloseOrders(magicHedge);
            reOpenPrice = trailingPrice("down",0,reOpenDistance);
            state=Open_Hedge;
         }   
      break;
      case Finish:
         
      break;
   }      
      
   
   
  }  


bool CheckHedge(int cmd, int entryDistance)
{  //We check that price exists to open a hedge position
   if(cmd == OP_SELLSTOP)
   {
      return true;
   }else if(cmd == OP_BUYSTOP)
   {
      return true;
   }
   return true;
}

int MarketOrderSend(string symbol, int cmd, double volume, double price, int slipagge, double stoploss, double takeprofit, string comment)
{
   int newOrder;
   
   newOrder = OrderSend(symbol, cmd, volume, price, slippage, stoploss, takeprofit, NULL, magic);
   if(newOrder <= 0)Alert("OrderSend Error: ", GetLastError());
   
   return(newOrder);
}

void CloseOrders(int magic)
{
   for(int i = OrdersTotal()-1;i>=0;i--)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber() == magic)
      {
         if(OrderType() == OP_BUY)
         {
            OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),slippage);
         }
         if(OrderType() == OP_SELL)
         {
            OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),slippage);
         }
         
      }
   }
}