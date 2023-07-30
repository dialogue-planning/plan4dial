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
        (tried-create)
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
        (task-value-create_account)
    )
    (:action offer-transfer
        :parameters()
        :precondition
            (and
                (not (know__task))
                (not (tried-transfer))
                (not (force-statement))
            )
        :effect
            (labeled-oneof offer-transfer__start-task
                (outcome want-transfer
                    (and
                        (not (task-value-create_account))
                        (not (task-value-pay_bills))
                        (not (task-value-request_money))
                        (not (task-value-e-transfer))
                        (know__task)
                        (task-value-transfer_funds_between_accounts)
                    )
                )
                (outcome dont-want
                    (and
                        (force-statement)
                        (have-message)
                        (tried-transfer)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action get-transfer-options
        :parameters()
        :precondition
            (and
                (task-value-transfer_funds_between_accounts)
                (not (force-statement))
            )
        :effect
            (labeled-oneof get-transfer-options__get-options
                (outcome get-valid-options
                    (and
                        (know__account1)
                        (know__funds)
                        (know__account2)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action confirm-transfer
        :parameters()
        :precondition
            (and
                (know__funds)
                (not (force-statement))
                (know__account1)
                (know__account2)
                (task-value-transfer_funds_between_accounts)
            )
        :effect
            (labeled-oneof confirm-transfer__transfer
                (outcome complete
                    (and
                        (not (task-value-create_account))
                        (not (task-value-transfer_funds_between_accounts))
                        (not (task-value-pay_bills))
                        (not (task-value-request_money))
                        (not (know__task))
                        (not (know__account1))
                        (not (know__account2))
                        (tried-transfer)
                        (not (know__funds))
                        (not (task-value-e-transfer))
                    )
                )
            )
    )
    (:action offer-e-transfer
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__task))
                (not (tried-e-transfer))
            )
        :effect
            (labeled-oneof offer-e-transfer__start-task
                (outcome want-transfer
                    (and
                        (not (task-value-create_account))
                        (task-value-e-transfer)
                        (not (task-value-transfer_funds_between_accounts))
                        (not (task-value-pay_bills))
                        (not (task-value-request_money))
                        (know__task)
                    )
                )
                (outcome dont-want
                    (and
                        (tried-e-transfer)
                        (force-statement)
                        (have-message)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action get-e-transfer-options
        :parameters()
        :precondition
            (and
                (task-value-e-transfer)
                (not (force-statement))
            )
        :effect
            (labeled-oneof get-e-transfer-options__get-options
                (outcome get-valid-e-transfer
                    (and
                        (select-account)
                        (know__funds)
                        (know__contact)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action confirm-e-transfer
        :parameters()
        :precondition
            (and
                (task-value-e-transfer)
                (know__funds)
                (not (force-statement))
                (know__account1)
                (know__contact)
            )
        :effect
            (labeled-oneof confirm-e-transfer__reset
                (outcome complete
                    (and
                        (not (task-value-create_account))
                        (not (task-value-transfer_funds_between_accounts))
                        (not (task-value-pay_bills))
                        (not (know__contact))
                        (not (task-value-request_money))
                        (not (know__task))
                        (not (know__account1))
                        (not (know__funds))
                        (not (task-value-e-transfer))
                        (tried-e-transfer)
                    )
                )
            )
    )
    (:action offer-request
        :parameters()
        :precondition
            (and
                (not (know__task))
                (not (tried-request-money))
                (not (force-statement))
            )
        :effect
            (labeled-oneof offer-request__start-task
                (outcome want-transfer
                    (and
                        (not (task-value-create_account))
                        (not (task-value-transfer_funds_between_accounts))
                        (not (task-value-pay_bills))
                        (not (task-value-e-transfer))
                        (know__task)
                        (task-value-request_money)
                    )
                )
                (outcome dont-want
                    (and
                        (tried-request-money)
                        (force-statement)
                        (have-message)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action get-request-options
        :parameters()
        :precondition
            (and
                (task-value-request_money)
                (not (force-statement))
            )
        :effect
            (labeled-oneof get-request-options__get-options
                (outcome get-valid-request
                    (and
                        (know__funds)
                        (know__contact)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action confirm-request
        :parameters()
        :precondition
            (and
                (know__funds)
                (task-value-request_money)
                (know__contact)
                (not (force-statement))
            )
        :effect
            (labeled-oneof confirm-request__reset
                (outcome complete
                    (and
                        (not (task-value-create_account))
                        (not (task-value-transfer_funds_between_accounts))
                        (not (task-value-pay_bills))
                        (not (know__contact))
                        (not (task-value-request_money))
                        (not (know__task))
                        (not (know__funds))
                        (not (task-value-e-transfer))
                        (tried-request-money)
                    )
                )
            )
    )
    (:action offer-pay
        :parameters()
        :precondition
            (and
                (not (know__task))
                (not (tried-pay-bills))
                (not (force-statement))
            )
        :effect
            (labeled-oneof offer-pay__start-task
                (outcome want-pay
                    (and
                        (task-value-pay_bills)
                        (not (task-value-create_account))
                        (not (task-value-transfer_funds_between_accounts))
                        (not (task-value-request_money))
                        (not (task-value-e-transfer))
                        (know__task)
                    )
                )
                (outcome dont-want
                    (and
                        (force-statement)
                        (have-message)
                        (tried-pay-bills)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action confirm-bill-payment
        :parameters()
        :precondition
            (and
                (know__account1)
                (task-value-pay_bills)
                (know__bill)
                (not (force-statement))
            )
        :effect
            (labeled-oneof confirm-bill-payment__reset
                (outcome complete
                    (and
                        (not (task-value-create_account))
                        (not (know__bill))
                        (not (task-value-transfer_funds_between_accounts))
                        (not (task-value-pay_bills))
                        (tried-pay-bills)
                        (not (task-value-request_money))
                        (not (know__task))
                        (not (know__account1))
                        (not (task-value-e-transfer))
                    )
                )
            )
    )
    (:action offer-new
        :parameters()
        :precondition
            (and
                (not (know__task))
                (not (tried-create))
                (not (force-statement))
            )
        :effect
            (labeled-oneof offer-new__start-task
                (outcome want-create
                    (and
                        (not (task-value-transfer_funds_between_accounts))
                        (not (task-value-pay_bills))
                        (not (task-value-request_money))
                        (not (task-value-e-transfer))
                        (know__task)
                        (task-value-create_account)
                    )
                )
                (outcome dont-want
                    (and
                        (tried-create)
                        (force-statement)
                        (have-message)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action confirm-create
        :parameters()
        :precondition
            (and
                (know__account1)
                (not (force-statement))
                (task-value-create_account)
                (know__account2)
            )
        :effect
            (labeled-oneof confirm-create__reset
                (outcome complete
                    (and
                        (not (task-value-create_account))
                        (not (task-value-transfer_funds_between_accounts))
                        (not (task-value-pay_bills))
                        (not (task-value-request_money))
                        (not (know__task))
                        (tried-create)
                        (not (know__account1))
                        (not (know__account2))
                        (not (task-value-e-transfer))
                    )
                )
            )
    )
    (:action complete
        :parameters()
        :precondition
            (and
                (tried-pay-bills)
                (tried-create)
                (tried-transfer)
                (not (force-statement))
                (tried-request-money)
                (tried-e-transfer)
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
                (force-statement)
                (have-message)
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
                (select-account)
                (not (know__account1))
                (not (force-statement))
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
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action slot-fill__get-payment
        :parameters()
        :precondition
            (and
                (task-value-pay_bills)
                (not (know__bill))
                (not (force-statement))
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
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action slot-fill__get-create
        :parameters()
        :precondition
            (and
                (task-value-create_account)
                (not (know__account2))
                (not (force-statement))
            )
        :effect
            (labeled-oneof slot-fill__get-create__validate-slot-fill
                (outcome account2_found
                    (and
                        (select-account)
                        (force-statement)
                        (have-message)
                        (know__account2)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
)
