CREATE UNIQUE INDEX idx_unique_volonteer_id ON volonteer (id_volonteer);
CREATE UNIQUE INDEX idx_unique_volonteer_email ON volonteer (email);                
CREATE UNIQUE INDEX idx_unique_feedback_id ON feedback (id_feedback);
CREATE UNIQUE INDEX idx_unique_feedback_training_volonteer ON feedback (id_training, id_volonteer);  
CREATE UNIQUE INDEX idx_unique_training_id ON training (id_training);
CREATE UNIQUE INDEX idx_unique_training_name ON training (name);




