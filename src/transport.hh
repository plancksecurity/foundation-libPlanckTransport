#ifndef __PEP_TRANSPORT_HH__
#define __PEP_TRANSPORT_HH__

#include <exception>
#include <stdexcept>
#include <string>
#include <functional>
// #include <pEp/types.hh>
#include <pEp/transport.h>

namespace pEp {

    // The implementation of the execution model is async/non-blocking using threads.
    class Transport {
    public:
        using CBStatusChange = std::function<
            void(const PEP_transport_id& id, const PEP_transport_status_code& tsc)>;
        using CBSendToResult = std::function<void(
            const PEP_transport_id& id,
            const std::string& message_id,
            //TODO: clarify with fdik: originally there was rating and address, too in here:
            // but i dont have neither of those in avail. in my transport
            // I only have a message status in form of a TSC
            // const std::string& address,
            // const pEpRating& rating
            const PEP_transport_status_code& tsc)>;
        using CBIncomminMessage = std::function<
            void(const PEP_transport_id& id, const PEP_transport_status_code& tsc)>;

        struct TransportError : std::runtime_error {
            const PEP_transport_status_code tsc;

            explicit TransportError(PEP_transport_status_code tsc) :
                std::runtime_error("transport error"), tsc(tsc)
            {
            }
        };

        struct ConfigError : std::logic_error {
            ConfigError() : std::logic_error("config error") {}
        };

        class Config {
        public:
            virtual ~Config() = 0;
        };

        // required for compat with the c interface transport.h because of missing polymorphism in c
        virtual PEP_transport_id get_id() = 0;

        // Callbacks
        // ---------
        // the signal_ function register signal handlers
        // they must be called while a transport is running, otherwise they
        // throw std::logic_error in case the transport is shut down
        // TODO: heck: "They" refers to the handlers, not the register functions
        // TODO: can we call them "register_", "callback_  or "cb_"?
        // equivalent of transport.h:
        //        typedef PEP_STATUS (*signal_statuschange_t)(PEP_transport_id id, PEP_transport_status_code tsc);
        // TODO terminology suggestion:
        // signal_transport_status() (using PEP_transport_status)
        virtual void signal_statuschange(CBStatusChange handler) = 0;

        // equivalent of transport.h:
        //        typedef PEP_STATUS (*signal_sendto_result_t)(
        //            PEP_transport_id id,
        //            char* message_id,
        //            char* address,
        //            PEP_rating rating,
        //            PEP_transport_status_code tsc);
        // TODO terminology suggestion:
        // signal_message_status() (using PEP_message_status)
        virtual void signal_sendto_result(CBSendToResult handler) = 0;

        // Called on every message added to rx-queue
        // The message can be fetched using recvnext()
        // equivalent of transport.h:
        //        typedef PEP_STATUS (
        //            *signal_incoming_message_t)(PEP_transport_id id, PEP_transport_status_code tsc);
        virtual void signal_incoming_message(CBIncomminMessage handler) = 0;

        virtual void configure(const Config& config) = 0;
        virtual void startup() = 0;
        virtual void shutdown() = 0;

        // non-blocking
        // Pushes the msg onto the tx-queue.
        // Throws TransportError with tsc tx_queue_overrun if the tx_queue is full.
        virtual void sendto(::message* msg) = 0;

        // non-blocking
        // pops the next msg off the rx-queue
        // Throws TransportError with tsc rx_queue_underrun if there is no message left to be received
        // this only needs to be called after asignal_incoming_message() has been received.
        virtual message* recvnext() = 0;

        virtual bool shortmsg_supported() = 0;
        virtual bool longmsg_supported() = 0;
        virtual bool longmsg_formatted_supported() = 0;
        virtual PEP_text_format native_text_format() = 0;
    };
} // namespace pEp

#endif // __PEP_TRANSPORT_HH__
