(define
    (domain bank-bot)
    (:requirements :strips)
    (:types )
    (:constants )
    (:predicates
        (select-account)
        (know__task)
        (tried-transfer)
        (tried-e-transfer)
        (tried-request-money)
        (tried-pay-bills)
        (tried-cancel)
        (know__account1)
        (know__account2)
        (know__funds)
        (know__contact)
        (know__bill)
        (know__goal)
        (goal)
        (have-message)
        (force-statement)
        (task-value-transfer_funds_between_accounts)
        (task-value-e-transfer)
        (task-value-request_money)
        (task-value-pay_bills)
        (task-value-cancel_account)
    )
    (:action offer-transfer
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__task))
                (not (tried-transfer))
            )
        :effect
            (labeled-oneof offer-transfer__start-task
                (outcome want-transfer
                    (and
                        (know__task)
                        (not (task-value-request_money))
                        (not (task-value-e-transfer))
                        (not (task-value-cancel_account))
                        (task-value-transfer_funds_between_accounts)
                        (not (task-value-pay_bills))
                    )
                )
                (outcome dont-want
                    (and
                        (have-message)
                        (tried-transfer)
                        (force-statement)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action get-transfer-options
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (task-value-transfer_funds_between_accounts)
            )
        :effect
            (labeled-oneof get-transfer-options__get-options
                (outcome get-valid-options
                    (and
                        (know__account1)
                        (know__account2)
                        (know__funds)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action confirm-transfer
        :parameters()
        :precondition
            (and
                (task-value-transfer_funds_between_accounts)
                (know__account2)
                (know__funds)
                (not (force-statement))
                (know__account1)
            )
        :effect
            (labeled-oneof confirm-transfer__transfer
                (outcome complete
                    (and
                        (not (know__task))
                        (not (know__account2))
                        (not (task-value-transfer_funds_between_accounts))
                        (not (know__account1))
                        (not (task-value-e-transfer))
                        (not (task-value-request_money))
                        (not (task-value-cancel_account))
                        (not (know__funds))
                        (not (task-value-pay_bills))
                        (tried-transfer)
                    )
                )
            )
    )
    (:action offer-e-transfer
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (tried-e-transfer))
                (not (know__task))
            )
        :effect
            (labeled-oneof offer-e-transfer__start-task
                (outcome want-transfer
                    (and
                        (know__task)
                        (task-value-e-transfer)
                        (not (task-value-transfer_funds_between_accounts))
                        (not (task-value-request_money))
                        (not (task-value-cancel_account))
                        (not (task-value-pay_bills))
                    )
                )
                (outcome dont-want
                    (and
                        (have-message)
                        (tried-e-transfer)
                        (force-statement)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action get-e-transfer-options
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (task-value-e-transfer)
            )
        :effect
            (labeled-oneof get-e-transfer-options__get-options
                (outcome get-valid-e-transfer
                    (and
                        (select-account)
                        (know__contact)
                        (know__funds)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action confirm-e-transfer
        :parameters()
        :precondition
            (and
                (task-value-e-transfer)
                (know__contact)
                (know__funds)
                (not (force-statement))
                (know__account1)
            )
        :effect
            (labeled-oneof confirm-e-transfer__reset
                (outcome complete
                    (and
                        (tried-e-transfer)
                        (not (know__task))
                        (not (know__contact))
                        (not (task-value-transfer_funds_between_accounts))
                        (not (task-value-request_money))
                        (not (know__account1))
                        (not (task-value-e-transfer))
                        (not (task-value-cancel_account))
                        (not (know__funds))
                        (not (task-value-pay_bills))
                    )
                )
            )
    )
    (:action offer-request
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (tried-request-money))
                (not (know__task))
            )
        :effect
            (labeled-oneof offer-request__start-task
                (outcome want-transfer
                    (and
                        (know__task)
                        (not (task-value-transfer_funds_between_accounts))
                        (not (task-value-e-transfer))
                        (not (task-value-cancel_account))
                        (not (task-value-pay_bills))
                        (task-value-request_money)
                    )
                )
                (outcome dont-want
                    (and
                        (have-message)
                        (force-statement)
                        (tried-request-money)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action get-request-options
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (task-value-request_money)
            )
        :effect
            (labeled-oneof get-request-options__get-options
                (outcome get-valid-request
                    (and
                        (know__contact)
                        (know__funds)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action confirm-request
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (task-value-request_money)
                (know__contact)
                (know__funds)
            )
        :effect
            (labeled-oneof confirm-request__reset
                (outcome complete
                    (and
                        (tried-request-money)
                        (not (know__task))
                        (not (know__contact))
                        (not (task-value-transfer_funds_between_accounts))
                        (not (task-value-request_money))
                        (not (task-value-e-transfer))
                        (not (task-value-cancel_account))
                        (not (know__funds))
                        (not (task-value-pay_bills))
                    )
                )
            )
    )
    (:action offer-pay
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__task))
                (not (tried-pay-bills))
            )
        :effect
            (labeled-oneof offer-pay__start-task
                (outcome want-pay
                    (and
                        (know__task)
                        (not (task-value-transfer_funds_between_accounts))
                        (not (task-value-request_money))
                        (not (task-value-e-transfer))
                        (not (task-value-cancel_account))
                        (task-value-pay_bills)
                    )
                )
                (outcome dont-want
                    (and
                        (have-message)
                        (tried-pay-bills)
                        (force-statement)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action confirm-bill-payment
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (task-value-pay_bills)
                (know__bill)
            )
        :effect
            (labeled-oneof confirm-bill-payment__reset
                (outcome complete
                    (and
                        (not (know__task))
                        (not (task-value-transfer_funds_between_accounts))
                        (not (task-value-request_money))
                        (not (task-value-e-transfer))
                        (not (know__bill))
                        (tried-pay-bills)
                        (not (task-value-cancel_account))
                        (not (task-value-pay_bills))
                    )
                )
            )
    )
    (:action offer-cancel
        :parameters()
        :precondition
            (and
                (not (tried-cancel))
                (not (force-statement))
                (not (know__task))
            )
        :effect
            (labeled-oneof offer-cancel__start-task
                (outcome want-cancel
                    (and
                        (know__task)
                        (not (task-value-transfer_funds_between_accounts))
                        (not (task-value-request_money))
                        (not (task-value-e-transfer))
                        (not (task-value-pay_bills))
                        (task-value-cancel_account)
                    )
                )
                (outcome dont-want
                    (and
                        (tried-cancel)
                        (have-message)
                        (force-statement)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action confirm-cancel
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (know__account1)
                (know__account2)
                (task-value-cancel_account)
            )
        :effect
            (labeled-oneof confirm-cancel__reset
                (outcome complete
                    (and
                        (not (know__task))
                        (not (task-value-transfer_funds_between_accounts))
                        (not (task-value-request_money))
                        (not (know__account1))
                        (not (task-value-e-transfer))
                        (not (task-value-cancel_account))
                        (tried-cancel)
                        (not (task-value-pay_bills))
                        (not (know__account2))
                    )
                )
            )
    )
    (:action complete
        :parameters()
        :precondition
            (and
                (tried-e-transfer)
                (not (force-statement))
                (tried-request-money)
                (tried-pay-bills)
                (tried-cancel)
                (tried-transfer)
            )
        :effect
            (labeled-oneof complete__finish
                (outcome done
                    (and
                        (goal)
                    )
                )
            )
    )
    (:action dialogue_statement
        :parameters()
        :precondition
            (and
                (have-message)
                (force-statement)
            )
        :effect
            (labeled-oneof dialogue_statement__reset
                (outcome lock
                    (and
                        (not (have-message))
                        (not (force-statement))
                    )
                )
            )
    )
    (:action slot-fill__select-account
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__account1))
                (select-account)
            )
        :effect
            (labeled-oneof slot-fill__select-account__validate-slot-fill
                (outcome account1_found
                    (and
                        (know__account1)
                        (not (select-account))
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action slot-fill__get-payment
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__bill))
            )
        :effect
            (labeled-oneof slot-fill__get-payment__validate-slot-fill
                (outcome bill_found
                    (and
                        (select-account)
                        (know__bill)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action slot-fill__get-cancel
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__account2))
            )
        :effect
            (labeled-oneof slot-fill__get-cancel__validate-slot-fill
                (outcome account2_found
                    (and
                        (select-account)
                        (know__account2)
                        (force-statement)
                        (have-message)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
)