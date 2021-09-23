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

        class Config {
        public:
            Config() {}

            virtual Config& operator=(const Config& second) = 0;

            Config(const Config& second)
            {
                *this = second;
            }

            virtual ~Config() {}
        };

        Transport(PEP_transport_id id) : id(id), current_status(PEP_tsc_shut_down) {}

        Transport(const Transport&) = delete;
        Transport& operator=(const Transport&) = delete;

        virtual ~Transport() {}

        PEP_transport_id get_id()
        {
            return id;
        }

        // the signal_ function register signal handlers
        // they must be called while a transport is running, otherwise they
        // throw std::logic_error in case the transport is shut down

        virtual void signal_statuschange(std::function<void(PEP_transport_status_code)> handler) = 0;

        virtual void signal_sendto_result(
            std::function<void(std::string, std::string, PEP_transport_status_code)> handler) = 0;

        virtual void signal_incoming_message(std::function<void(PEP_transport_status_code)> handler) = 0;

        virtual void configure(const Config& config) = 0;
        virtual void startup(
            PEP_callback_execution_mode cbe = PEP_callback_execution_mode::PEP_cbe_polling) = 0;
        virtual void shutdown() = 0;

        virtual void sendto(Message& msg) = 0;
        virtual Message recvnext() = 0;

        virtual bool shortmsg_supported() = 0;
        virtual bool longmsg_supported() = 0;
        virtual bool longmsg_formatted_supported() = 0;
        virtual PEP_text_format native_text_format() = 0;
    };
} // namespace pEp

#endif // __PEP_TRANSPORT_HH__
