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

//Variables
input int magic = 17;
input double lots = 0.01;
input double SL = 20;
input double TP = 1.2;
input double startPrice = 1.14;
input double hedge = 500; //distance in points (not pips) from the low to SL - Entry point for hedge
bool oportunity = true;
int slippage = 10;

//state = Hedge
double reOpenPrice = 0;
double distance = 500*_Point;

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
            state = Start; 
         }
                 
         break;
      case Start:
         {
            //int testBuy = OrderSend(symbol,cmd,volume,price,slippage,stoploss,takeprofit,comment,magic,dateexpiration,color);
            int buyStop = MarketOrderSend(NULL,OP_BUYSTOP,lots,Ask+500*_Point,slippage,NULL,TP,NULL);
            int buyPrice = OrderSelect(0,SELECT_BY_POS,MODE_TRADES);
            
            double low = 999999; //30 day low - Local variable
            for(int i = 0;i < 30;i++)
            {
               //Calculate 7-day low to put our hedge position
               if(iLow(NULL,PERIOD_D1,i) < low)
               {
                  low = iLow(NULL,PERIOD_D1,i);
               } 
            }
            int sellStop = MarketOrderSend(NULL,OP_SELLSTOP,lots,low-hedge*_Point,slippage,NULL,NULL,NULL);
            
            //Our initial position has been set, so we now start to manage our position via hedging
            state = Hedge;      
            break;
         }         
      case Hedge:
      reOpenPrice = trailingPrice("buy", reOpenPrice, distance);
      
         if(Ask >= reOpenPrice  && OrdersTotal()==2)
         {
            //We close the last sell order. A buy + a sell = position with hedge. Closing a sell means closing the hedge and going long 
            int closeOrder = OrderSelect(1,SELECT_BY_POS,MODE_TRADES);
            if(OrderType()==OP_SELL)
            {  //We close an opened order
               int closeSellStop = OrderClose(OrderTicket(),lots,Ask,10,clrRed);
            }else if(OrderType()==OP_SELLSTOP)
            {  //We close a pending order
               int closeSellStop = OrderDelete(OrderTicket(),clrRed);
            }      
            
            //We check that sell stop order can be sent to market
            if(iLow(NULL,PERIOD_D1,1)-50*_Point < Bid+10*_Point)
            {
               int sellStop2 = MarketOrderSend(NULL,OP_SELLSTOP,lots,iLow(NULL,PERIOD_D1,1)-50*_Point,slippage,NULL,NULL,NULL);
            }else
            {
               int sellStop2 = MarketOrderSend(NULL,OP_SELLSTOP,lots,Bid-50*_Point,slippage,NULL,NULL,NULL);
            }
         }   
      
         break;
      case Finish:
      
      
         break; 
      default:
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


/*
if(buyInterest()==true && OrdersTotal() < 2)
         {
            //int testBuy = OrderSend(symbol,cmd,volume,price,slippage,stoploss,takeprofit,comment,magic,dateexpiration,color);
            int buy = MarketOrderSend(NULL,OP_BUY,lots,Ask,slippage,NULL,TP,NULL);
            int sellStop = MarketOrderSend(NULL,OP_SELLSTOP,lots,iLow(NULL,PERIOD_D1,1)-20*_Point,slippage,NULL,NULL,NULL);
         }else if(buyInterest()==true && OrdersTotal()==2)
         {
            //We close the last sell order. A buy + a sell = position with hedge. Closing a sell means closing the hedge and going long 
            int closeOrder = OrderSelect(1,SELECT_BY_POS,MODE_TRADES);
            if(OrderType()==OP_SELL)
            {  //We close an opened order
               int closeSellStop = OrderClose(OrderTicket(),lots,Ask,10,clrRed);
            }else if(OrderType()==OP_SELLSTOP)
            {  //We close a pending order
               int closeSellStop = OrderDelete(OrderTicket(),clrRed);
            }      
            
            //We check that sell stop order can be sent to market
            if(iLow(NULL,PERIOD_D1,1)-50*_Point < Bid+10*_Point)
            {
               int sellStop2 = MarketOrderSend(NULL,OP_SELLSTOP,lots,iLow(NULL,PERIOD_D1,1)-50*_Point,slippage,NULL,NULL,NULL);
            }else
            {
               int sellStop2 = MarketOrderSend(NULL,OP_SELLSTOP,lots,Bid-50*_Point,slippage,NULL,NULL,NULL);
            }
         } 
*/