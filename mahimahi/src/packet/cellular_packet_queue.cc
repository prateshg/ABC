#include <chrono>

#include "cellular_packet_queue.hh"
#include "timestamp.hh"
#include <iostream>

using namespace std;

CELLULARPacketQueue::CELLULARPacketQueue( const string & args )
  : DroppingPacketQueue(args),
    qdelay_ref_ ( get_arg( args, "qdelay_ref" ) ),
    beta_ ( get_arg( args,  "beta" ) / 100.0),
    observed_dq_queue ( {0} ),
    real_dq_queue ( {0} ),
    credits (5)
{
  if ( qdelay_ref_ == 0 || beta_==0) {
    throw runtime_error( "CELLULAR AQM queue must have qdelay_ref, beta" );
  }
}

void CELLULARPacketQueue::enqueue( QueuedPacket && p )
{


  if ( ! good_with( size_bytes() + p.contents.size(),
        size_packets() + 1 ) ) {
    // Internal queue is full. Packet has to be dropped.
    return;
  } 

  accept( std::move( p ) );

  assert( good() );
}


QueuedPacket CELLULARPacketQueue::dequeue( void )
{
  uint32_t now = timestamp();
  while(now-real_dq_queue[0]>20 && real_dq_queue.size()>1 && now>real_dq_queue[1]) {
    real_dq_queue.pop_front();
  }
  real_dq_queue.push_back(now);
  
  if(size_packets()==0) {
    return QueuedPacket("arbit", 0);
  }

  QueuedPacket ret = std::move( DroppingPacketQueue::dequeue () );
  while(now-observed_dq_queue[0]>20 && observed_dq_queue.size()>1 && now>observed_dq_queue[1]) {
    observed_dq_queue.pop_front();
   }
  observed_dq_queue.push_back(now);
   
  double delta = 100.0;   //For stabilitilt delta should be greater than max RTT
  
  double real_dq_rate_, observed_dq_rate_, target_rate;
  real_dq_rate_ = (real_dq_queue.size()-1)/20.0;
  observed_dq_rate_ = (observed_dq_queue.size()-1)/20.0;

  double current_qdelay = (size_packets() + 1) / real_dq_rate_;
  target_rate = 0.98*real_dq_rate_ + beta_ * (real_dq_rate_ / delta) * min(0.0, (qdelay_ref_ - current_qdelay));  
  double credit_prob_ = (target_rate /  observed_dq_rate_) * 0.5;

  credit_prob_ = max(0.0,credit_prob_);
  credit_prob_ = min(1.0, credit_prob_);
  credits += credit_prob_;
  
  if (credits > 5) {
    credits = 5;
  }
  if (credits > 1) {
    if (ret.contents[ret.contents.size() - 1] == ret.contents[ret.contents.size() - 3]) {
      credits -= 1;
    }
  } else {
    ret.contents[ret.contents.size() - 1] = ret.contents[ret.contents.size() - 1] + 1;
    ret.contents[ret.contents.size() - 3] = ret.contents[ret.contents.size() - 3] - 1;
  }
  return ret;
}