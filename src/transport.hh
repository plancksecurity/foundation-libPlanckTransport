#ifndef __PEP_TRANSPORT_HH__
#define __PEP_TRANSPORT_HH__

#include <exception>
#include <functional>
#include <pEp/transport_status_code.h>
#include <pEp/types.hh>
#include <pEp/transport.h>

namespace pEp {
    class Transport {
    public:
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

        // Abs. Baseclass for config
        class Config {
        public:
            Config() = default;
            virtual ~Config() = 0;
        };

        explicit Transport(PEP_transport_id id) : id(id), current_status(PEP_tsc_shut_down) {}
        Transport(const Transport&) = delete;
        Transport& operator=(const Transport&) = delete;
        virtual ~Transport() = default;

        PEP_transport_id get_id()
        {
            return id;
        }

        // the signal_ function register signal handlers
        // they must be called while a transport is running, otherwise they
        // throw std::logic_error in case the transport is shut down
        // TODO: heck: "They" refers to the handlers, not the register functions
        // can we call them "register_"
        virtual void signal_statuschange(std::function<void(PEP_transport_status_code)> handler) = 0;

        virtual void signal_sendto_result(
            std::function<void(std::string, std::string, PEP_transport_status_code)> handler) = 0;

        // Called on every message added to rx-queue
        // The message can be fetched using recvnext()
        // in case of callback_execution:::PEP_cbe_polling
        // This callback is not expected to be used
        virtual void signal_incoming_message(std::function<void(PEP_transport_status_code)> handler) = 0;

        virtual void configure(const Config& config) = 0;
        virtual void startup(callback_execution cbe = PEP_cbe_polling) = 0;
        virtual void shutdown() = 0;

        // non-blocking
        // Does not throw or deliver any kind of status, since it only puts the message on the
        // tx-queue which succeeds always
        // TODO: what id the queue is full? std::overflow_error?
        virtual void sendto(Message& msg) = 0;

        // Potentially throws TransportError
        // In case of callback_execution:::PEP_cbe_polling this needs to called repeatedly.
        // In case of callback_execution:::PEP_cbe_async this only needs to be called after a
        // signal_incoming_message() has been received.
        virtual Message recvnext() = 0;

        virtual bool shortmsg_supported() = 0;
        virtual bool longmsg_supported() = 0;
        virtual bool longmsg_formatted_supported() = 0;
        virtual PEP_text_format native_text_format() = 0;
    };
} // namespace pEp

#endif // __PEP_TRANSPORT_HH__
