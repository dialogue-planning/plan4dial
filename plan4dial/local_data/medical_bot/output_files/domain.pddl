(define
    (domain medical_bot)
    (:requirements :strips)
    (:types )
    (:constants )
    (:predicates
        (know__covid-exposure)
        (covid-exposure)
        (know__have-symptoms)
        (have-symptoms)
        (know__exposure-period-over-5)
        (exposure-period-over-5)
        (know__positive-30)
        (positive-30)
        (know__positive-90)
        (positive-90)
        (know__should-test)
        (should-test)
        (goal)
        (have-message)
        (force-statement)
    )
    (:action determine_test
        :parameters()
        :precondition
            (and
                (know__positive-90)
                (know__have-symptoms)
                (know__covid-exposure)
                (know__exposure-period-over-5)
                (not (force-statement))
                (know__positive-30)
            )
        :effect
            (labeled-oneof determine_test__check-test
                (outcome no-symptom-exposed-been-5
                    (and
                        (force-statement)
                        (have-message)
                        (know__should-test)
                        (should-test)
                    )
                )
                (outcome no-symptom-exposed-less-5
                    (and
                        (not (should-test))
                        (force-statement)
                        (have-message)
                        (know__should-test)
                    )
                )
                (outcome have-symptoms-no-90
                    (and
                        (force-statement)
                        (have-message)
                        (know__should-test)
                        (should-test)
                    )
                )
                (outcome have-symptoms-30
                    (and
                        (force-statement)
                        (have-message)
                        (know__should-test)
                        (should-test)
                    )
                )
                (outcome have-no-symptoms-30
                    (and
                        (not (should-test))
                        (force-statement)
                        (have-message)
                        (know__should-test)
                    )
                )
                (outcome have-symptoms-90
                    (and
                        (force-statement)
                        (have-message)
                        (know__should-test)
                        (should-test)
                    )
                )
                (outcome have-no-symptoms-90
                    (and
                        (force-statement)
                        (have-message)
                        (know__should-test)
                        (should-test)
                    )
                )
            )
    )
    (:action complete
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (know__should-test)
            )
        :effect
            (labeled-oneof complete__finish
                (outcome finish
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
    (:action slot-fill__get_covid_exposure
        :parameters()
        :precondition
            (and
                (not (know__covid-exposure))
                (not (force-statement))
            )
        :effect
            (labeled-oneof slot-fill__get_covid_exposure__get-response
                (outcome confirm_outcome
                    (and
                        (know__covid-exposure)
                        (covid-exposure)
                    )
                )
                (outcome deny_outcome
                    (and
                        (know__covid-exposure)
                        (not (covid-exposure))
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
    (:action slot-fill__get_have_symptoms
        :parameters()
        :precondition
            (and
                (know__covid-exposure)
                (not (know__have-symptoms))
                (not (force-statement))
            )
        :effect
            (labeled-oneof slot-fill__get_have_symptoms__get-response
                (outcome confirm_outcome
                    (and
                        (know__have-symptoms)
                        (have-symptoms)
                    )
                )
                (outcome deny_outcome
                    (and
                        (know__have-symptoms)
                        (not (have-symptoms))
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
    (:action slot-fill__get_exposure_period
        :parameters()
        :precondition
            (and
                (know__covid-exposure)
                (not (force-statement))
                (not (know__exposure-period-over-5))
            )
        :effect
            (labeled-oneof slot-fill__get_exposure_period__get-response
                (outcome confirm_outcome
                    (and
                        (know__exposure-period-over-5)
                        (exposure-period-over-5)
                    )
                )
                (outcome deny_outcome
                    (and
                        (know__exposure-period-over-5)
                        (not (exposure-period-over-5))
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
    (:action slot-fill__get_positive_30
        :parameters()
        :precondition
            (and
                (know__covid-exposure)
                (not (force-statement))
                (not (know__positive-30))
            )
        :effect
            (labeled-oneof slot-fill__get_positive_30__get-response
                (outcome confirm_outcome
                    (and
                        (positive-30)
                        (know__positive-30)
                    )
                )
                (outcome deny_outcome
                    (and
                        (know__positive-30)
                        (not (positive-30))
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
    (:action slot-fill__get_positive_90
        :parameters()
        :precondition
            (and
                (know__positive-30)
                (not (force-statement))
                (not (know__positive-90))
            )
        :effect
            (labeled-oneof slot-fill__get_positive_90__get-response
                (outcome confirm_outcome
                    (and
                        (positive-90)
                        (know__positive-90)
                    )
                )
                (outcome deny_outcome
                    (and
                        (know__positive-90)
                        (not (positive-90))
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